import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/entities/delivery_info.dart';

import 'auction_paging_models.dart';

final auctionRepositoryProvider = Provider((ref) => AuctionRepository());

class AuctionRepository {
  final FirebaseFirestore _firestore;

  AuctionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _guessImageContentType({required Uint8List bytes, String? fileName}) {
    final name = (fileName ?? '').toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';

    // Magic numbers (best-effort)
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // Default to a supported type to satisfy Storage rules.
    return 'image/jpeg';
  }

  Uint8List _compressForFirestore(Uint8List inputBytes, {required int targetMaxBytes}) {
    try {
      final decoded = img.decodeImage(inputBytes);
      if (decoded == null) return inputBytes;

      // Resize to a reasonable max side so Firestore base64 stays small.
      const int maxSide = 1280;
      img.Image processed = decoded;
      final int w = decoded.width;
      final int h = decoded.height;
      if (w > maxSide || h > maxSide) {
        if (w >= h) {
          processed = img.copyResize(decoded, width: maxSide);
        } else {
          processed = img.copyResize(decoded, height: maxSide);
        }
      }

      int quality = 85;
      Uint8List out = Uint8List.fromList(img.encodeJpg(processed, quality: quality));
      while (out.lengthInBytes > targetMaxBytes && quality > 35) {
        quality -= 10;
        out = Uint8List.fromList(img.encodeJpg(processed, quality: quality));
      }
      return out;
    } catch (_) {
      return inputBytes;
    }
  }

  Future<void> createAuction({
    required String title,
    required String description,
    required String category,
    required double startPrice,
    required DateTime endDate,
    required Object imageFile, // File, XFile or Uint8List
    required String sellerId,
    double? buyoutPrice,
  }) async {
    // Basic validation
    if (title.trim().isEmpty) {
      throw Exception('Назва лота не може бути порожньою.');
    }
    if (startPrice <= 0) {
      throw Exception('Початкова ціна має бути більше нуля.');
    }
    if (endDate.isBefore(DateTime.now())) {
      throw Exception('Дата завершення має бути в майбутньому.');
    }
    if (sellerId.trim().isEmpty) throw Exception('sellerId відсутній.');

    final docRef = _firestore.collection('auctions').doc();
    final auctionId = docRef.id;

    // Maximum raw bytes allowed for Base64 in Firestore (to avoid document size limits)
    const int maxImageBytes = 512 * 1024; // 512 KB
    const int maxStorageBytes = 10 * 1024 * 1024; // 10 MB (must match Storage rules)
    const Duration firestoreWriteTimeout = Duration(seconds: 20);
    const Duration uploadTimeout = Duration(seconds: 45);
    const Duration downloadUrlTimeout = Duration(seconds: 20);

    final total = Stopwatch()..start();
    String stage = 'init';

    void mark(String s) {
      stage = s;
      developer.log('[createAuction] stage=$stage elapsedMs=${total.elapsedMilliseconds} auctionId=$auctionId');
    }

    try {
      Uint8List bytes;
      String? fileName;

      mark('readImage');

      if (imageFile is XFile) {
        bytes = await imageFile.readAsBytes();
        fileName = imageFile.name;
      } else if (imageFile is Uint8List) {
        bytes = imageFile;
      } else if (imageFile is List<int>) {
        bytes = Uint8List.fromList(imageFile);
      } else {
        final dynamic f = imageFile;
        if (f == null) throw Exception('imageFile відсутній.');
        try {
          final dynamic result = await f.readAsBytes();
          if (result is Uint8List) {
            bytes = result;
          } else if (result is List<int>) {
            bytes = Uint8List.fromList(result);
          } else {
            throw Exception('Unsupported readAsBytes result.');
          }
        } catch (e) {
          throw Exception('Не вдалося прочитати файл зображення: $e');
        }
      }

      mark('prepareData');

      String? base64Image;
      String imageUrl = '';

      // On web, prefer Firestore base64 to avoid Storage+CORS/emulator issues.
      // We compress/resize the image to fit the Firestore document limit.
      final bool useFirestoreImageOnWeb = kIsWeb;
      if (bytes.isNotEmpty) {
        if (bytes.lengthInBytes <= maxImageBytes) {
          base64Image = base64Encode(bytes);
        } else if (useFirestoreImageOnWeb) {
          final compressed = _compressForFirestore(bytes, targetMaxBytes: maxImageBytes);
          if (compressed.lengthInBytes <= maxImageBytes) {
            base64Image = base64Encode(compressed);
          } else {
            throw Exception('Фото занадто велике для Web-версії. Оберіть менше фото.');
          }
        }
      }

      // 1) Create the Firestore doc FIRST.
      // This is required because Storage rules validate sellerId via Firestore document.
      final auction = AuctionEntity(
        id: auctionId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        imageBase64: base64Image,
        category: category.trim(),
        startPrice: startPrice,
        currentPrice: startPrice,
        buyoutPrice: buyoutPrice,
        endDate: endDate,
        sellerId: sellerId,
      );
      mark('firestoreCreate');
      await docRef.set(auction.toDocument()).timeout(firestoreWriteTimeout);

      // 2) If image is too large for Firestore, upload to Storage and update the doc.
      if (bytes.isNotEmpty && bytes.lengthInBytes > maxImageBytes && !useFirestoreImageOnWeb) {
        if (bytes.lengthInBytes >= maxStorageBytes) {
          throw Exception('Зображення завелике (>${maxStorageBytes ~/ (1024 * 1024)}MB). Оберіть файл до 10MB.');
        }

        final imageId = const Uuid().v4();
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('auction_images/$auctionId/$imageId');

        final contentType = _guessImageContentType(bytes: bytes, fileName: fileName);
        mark('storageUpload');
        final uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );

        // Prevent "infinite loading" on web due to network/CORS issues.
        // If it times out, cancel the task so it doesn't continue uploading in background.
        try {
          await uploadTask.timeout(
            uploadTimeout,
            onTimeout: () async {
              try {
                await uploadTask.cancel();
              } catch (_) {}
              throw TimeoutException('Upload timed out', uploadTimeout);
            },
          );
        } on TimeoutException {
          rethrow;
        }

        mark('storageGetDownloadUrl');
        imageUrl = await storageRef.getDownloadURL().timeout(downloadUrlTimeout);

        mark('firestoreUpdate');
        await docRef.update({
          'imageUrl': imageUrl,
          'imageBase64': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(firestoreWriteTimeout);
      }
    } on TimeoutException catch (e) {
      // Best-effort rollback to avoid creating "ghost" auctions.
      try {
        mark('rollbackDelete');
        await docRef.delete().timeout(const Duration(seconds: 10));
      } catch (_) {}
      throw Exception(
        'Таймаут створення лота на кроці "$stage" (≈${total.elapsed.inSeconds}s). Перевір: Storage (вкл/емулятор запущений), правила, CORS/мережа. Деталі: $e',
      );
    } catch (e) {
      try {
        mark('rollbackDelete');
        await docRef.delete().timeout(const Duration(seconds: 10));
      } catch (_) {}
      throw Exception('Помилка створення лота на кроці "$stage": $e');
    }
  }

  Stream<List<AuctionEntity>> getAuctionsStream() {
    return _firestore
        .collection('auctions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => AuctionEntity.fromDocument(d)).toList());
  }

  Future<AuctionPage> fetchAuctionsPage({
    QueryDocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = 20,
  }) async {
    final query = _firestore
        .collection('auctions')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final QuerySnapshot<Map<String, dynamic>> snapshot = startAfter == null
        ? await query.get()
        : await query.startAfterDocument(startAfter).get();

    final items =
        snapshot.docs.map((d) => AuctionEntity.fromDocument(d)).toList();
    final lastDoc = snapshot.docs.isEmpty ? null : snapshot.docs.last;

    // Heuristic: if we got less than limit, we likely reached the end.
    final hasMore = snapshot.docs.length == limit;

    return AuctionPage(items: items, lastDoc: lastDoc, hasMore: hasMore);
  }

  Future<void> updateAuction({
    required String auctionId,
    required String sellerId,
    required String title,
    required String description,
    required DateTime endDate,
    double? buyoutPrice,
  }) async {
    final auctionRef = _firestore.collection('auctions').doc(auctionId);

    if (title.trim().isEmpty) {
      throw Exception('Назва лота не може бути порожньою.');
    }
    if (description.trim().isEmpty) {
      throw Exception('Опис не може бути порожнім.');
    }
    if (endDate.isBefore(DateTime.now())) {
      throw Exception('Дата завершення має бути в майбутньому.');
    }

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(auctionRef);
      final data = snapshot.data();
      if (data == null) {
        throw Exception('Лот не знайдено.');
      }

      final existingSellerId = (data['sellerId'] as String?) ?? '';
      if (existingSellerId != sellerId) {
        throw Exception('Недостатньо прав для редагування цього лота.');
      }

      final status = (data['status'] as String?) ?? 'active';
      if (status != 'active') {
        throw Exception('Редагування доступне лише для активних лотів.');
      }

      final bidCount = (data['bidCount'] as int?) ?? 0;
      if (bidCount > 0) {
        // Keep rules simple and safe: after bids start, restrict changing end date / buyout.
        if (buyoutPrice != null) {
          throw Exception('Неможливо змінити ціну викупу після появи ставок.');
        }
        // We still allow editing title/description.
        transaction.update(auctionRef, {
          'title': title.trim(),
          'description': description.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      transaction.update(auctionRef, {
        'title': title.trim(),
        'description': description.trim(),
        'endDate': endDate.toIso8601String(),
        'buyoutPrice': buyoutPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> placeBid({
    required String auctionId,
    required double bidAmount,
    required String userId,
    required String userName,
  }) async {
    final auctionRef = _firestore.collection('auctions').doc(auctionId);
    final bidsRef = auctionRef.collection('bids');
    final userBidsRef =
        _firestore.collection('users').doc(userId).collection('bids');

    double numOrStringToDouble(dynamic v, {double fallback = double.nan}) {
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed =
            double.tryParse(v.trim().replaceAll(' ', '').replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(auctionRef);
      final data = snapshot.data();
      if (data == null) {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'not-found',
          message: 'Лот не знайдено.',
        );
      }

      final status = (data['status'] as String?) ?? 'active';
      if (status != 'active') {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Аукціон не активний.',
        );
      }

      DateTime? parseEndDate(dynamic raw) {
        if (raw is Timestamp) return raw.toDate();
        if (raw is String) return DateTime.tryParse(raw);
        return null;
      }

      final endDate = parseEndDate(data['endDate']);
      if (endDate != null) {
        final nowUtc = DateTime.now().toUtc();
        final endUtc = endDate.toUtc();
        if (nowUtc.isAfter(endUtc)) {
          throw FirebaseException(
            plugin: 'firestore',
            code: 'failed-precondition',
            message: 'Аукціон вже завершено.',
          );
        }
      }

      final currentPrice =
          numOrStringToDouble(data['currentPrice'], fallback: 0.0);
      final bidCount = (snapshot.data()?['bidCount'] as int?) ?? 0;

      final buyout = numOrStringToDouble(data['buyoutPrice']);
      if (!buyout.isNaN && buyout > 0 && bidAmount >= buyout) {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message:
              'Ставка не може бути більшою або рівною ціні викупу. Використайте кнопку "Викупити".',
        );
      }

      if (bidAmount <= currentPrice) {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Ставка має бути вищою за поточну ціну.',
        );
      }

      transaction.update(auctionRef, {
        'currentPrice': bidAmount,
        'bidCount': bidCount + 1,
        'lastBidderId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final bidData = {
        'userId': userId,
        'userName': userName,
        'amount': bidAmount,
        'timestamp': FieldValue.serverTimestamp(),
        'auctionId': auctionId,
      };

      transaction.set(bidsRef.doc(), bidData);
      transaction.set(userBidsRef.doc(), bidData);
    });
  }

  Future<void> confirmShipping(String auctionId, DeliveryInfo info) async {
    try {
      await _firestore.collection('auctions').doc(auctionId).update({
        'deliveryInfo': info.toMap(),
        'status': 'shipping_confirmed',
      });
    } catch (e) {
      throw Exception('Помилка збереження доставки: $e');
    }
  }

  Future<void> setPaymentMethod(String auctionId, PaymentMethod method) async {
    try {
      await _firestore.collection('auctions').doc(auctionId).update({
        'deliveryInfo.paymentMethod': method.name,
      });
    } catch (e) {
      throw Exception('Помилка збереження способу оплати: $e');
    }
  }

  Future<void> buyoutAuction({
    required String auctionId,
    required String buyerId,
    required String buyerName,
  }) async {
    final auctionRef = _firestore.collection('auctions').doc(auctionId);
    final bidsRef = auctionRef.collection('bids');
    final userBidsRef =
        _firestore.collection('users').doc(buyerId).collection('bids');

    double numOrStringToDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
      return double.nan;
    }

    DateTime? parseEndDate(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      return null;
    }

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(auctionRef);
      final data = snapshot.data();
      if (data == null) {
        throw FirebaseException(
            plugin: 'firestore',
            code: 'not-found',
            message: 'Auction not found');
      }

      final sellerId = (data['sellerId'] as String?) ?? '';
      if (sellerId.isNotEmpty && sellerId == buyerId) {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Seller cannot buy out own auction.',
        );
      }

      final status = (data['status'] as String?) ?? 'active';
      final normalizedStatus = status.trim().toLowerCase();
      if (normalizedStatus != 'active') {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Auction is not active.',
        );
      }

      final endDateRaw = data['endDate'];
      final endDate = parseEndDate(endDateRaw);
      if (endDate != null) {
        final nowUtc = DateTime.now().toUtc();
        final endUtc = endDate.toUtc();
        if (nowUtc.isAfter(endUtc)) {
          throw FirebaseException(
            plugin: 'firestore',
            code: 'failed-precondition',
            message: 'Auction has already ended.',
          );
        }
      }

      final buyout = numOrStringToDouble(data['buyoutPrice']);
      if (buyout.isNaN || buyout <= 0) {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Buyout is not available.',
        );
      }

      final bidCount = (data['bidCount'] as num?)?.toInt() ?? 0;

      transaction.update(auctionRef, {
        'currentPrice': buyout,
        'bidCount': bidCount + 1,
        'lastBidderId': buyerId,
        'winnerId': buyerId,
        'status': 'sold',
      });

      transaction.set(bidsRef.doc(), {
        'userId': buyerId,
        'userName': buyerName,
        'amount': buyout,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'buyout',
        'auctionId': auctionId,
      });
      transaction.set(userBidsRef.doc(), {
        'userId': buyerId,
        'userName': buyerName,
        'amount': buyout,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'buyout',
        'auctionId': auctionId,
      });
    });
  }

  Future<void> deleteAuction({
    required String auctionId,
    required String sellerId,
  }) async {
    final auctionRef = _firestore.collection('auctions').doc(auctionId);

    // Allow deletion even if bids exist.
    // Firestore does not automatically delete subcollections, so remove bids first.
    final snapshot = await auctionRef.get();
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Лот не знайдено.');
    }

    final existingSellerId = (data['sellerId'] as String?) ?? '';
    if (existingSellerId != sellerId) {
      throw Exception('Недостатньо прав для видалення цього лота.');
    }

    final status = (data['status'] as String?) ?? 'active';
    if (status != 'active') {
      throw Exception('Можна видаляти лише активні лоти.');
    }

    final bidsCol = auctionRef.collection('bids');
    while (true) {
      final batchSnapshot = await bidsCol.limit(400).get();
      if (batchSnapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final d in batchSnapshot.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }

    await auctionRef.delete();
  }
}
