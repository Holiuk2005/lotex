import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/entities/delivery_info.dart';

final auctionRepositoryProvider = Provider((ref) => AuctionRepository());

class AuctionRepository {
  final FirebaseFirestore _firestore;

  AuctionRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required Object imageFile, // File, XFile or Uint8List
    required String sellerId,
    double? buyoutPrice,
  }) async {
    // Basic validation
    if (title.trim().isEmpty) throw Exception('Назва лота не може бути порожньою.');
    if (startPrice <= 0) throw Exception('Початкова ціна має бути більше нуля.');
    if (endDate.isBefore(DateTime.now())) throw Exception('Дата завершення має бути в майбутньому.');
    if (sellerId.trim().isEmpty) throw Exception('sellerId відсутній.');

    try {
      final docRef = _firestore.collection('auctions').doc();
      final auctionId = docRef.id;

      String? base64Image;

      // Maximum raw bytes allowed for conversion to Base64 (to avoid Firestore document size limits)
      const int maxImageBytes = 512 * 1024; // 512 KB

      try {
        Uint8List bytes;

        if (imageFile is XFile) {
          bytes = await imageFile.readAsBytes();
        } else if (imageFile is Uint8List) {
          bytes = imageFile;
        } else if (imageFile is List<int>) {
          bytes = Uint8List.fromList(imageFile);
        } else {
          // Try dynamic readAsBytes if object exposes it (works for many file-like objects)
          final dynamic f = imageFile;
          if (f != null) {
            try {
              final read = f.readAsBytes;
              if (read is Function) {
                final dynamic result = await f.readAsBytes();
                if (result is Uint8List) {
                  bytes = result;
                } else if (result is List<int>) {
                  bytes = Uint8List.fromList(result);
                } else {
                  throw Exception('Unsupported readAsBytes result.');
                }
              } else {
                throw Exception('Unsupported imageFile type (no readAsBytes).');
              }
            } catch (e) {
              throw Exception('Не вдалося прочитати файл зображення: $e');
            }
          } else {
            throw Exception('imageFile відсутній.');
          }
        }

        if (bytes.isNotEmpty) {
          if (bytes.lengthInBytes > maxImageBytes) {
            throw Exception('Зображення занадто велике (${(bytes.lengthInBytes / 1024).toStringAsFixed(0)} KB). Використайте Firebase Storage або зменшіть розмір.');
          }

          base64Image = base64Encode(bytes);
        } else {
          base64Image = null;
        }
      } catch (e) {
        // Bubble up image errors as informative exceptions
        rethrow;
      }

      final auction = AuctionEntity(
        id: auctionId,
        title: title,
        description: description,
        imageUrl: '',
        imageBase64: base64Image,
        startPrice: startPrice,
        currentPrice: startPrice,
        buyoutPrice: buyoutPrice,
        endDate: endDate,
        sellerId: sellerId,
      );

      final data = auction.toDocument();
      data['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);
    } catch (e) {
      // Keep error message in Ukrainian for consistency
      throw Exception('Помилка створення лота: $e');
    }
  }

  Stream<List<AuctionEntity>> getAuctionsStream() {
    return _firestore
        .collection('auctions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => AuctionEntity.fromDocument(d)).toList());
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

    if (title.trim().isEmpty) throw Exception('Назва лота не може бути порожньою.');
    if (description.trim().isEmpty) throw Exception('Опис не може бути порожнім.');
    if (endDate.isBefore(DateTime.now())) throw Exception('Дата завершення має бути в майбутньому.');

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

      final currentPrice = (snapshot.data()?['currentPrice'] as num?)?.toDouble() ?? 0.0;
      final bidCount = (snapshot.data()?['bidCount'] as int?) ?? 0;

      final buyout = (data['buyoutPrice'] as num?)?.toDouble();
      if (buyout != null && buyout > 0 && bidAmount >= buyout) {
        throw FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'Ставка не може бути більшою або рівною ціні викупу. Використайте кнопку "Викупити".',
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
      });

      transaction.set(bidsRef.doc(), {
        'userId': userId,
        'userName': userName,
        'amount': bidAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });
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

  Future<void> buyoutAuction({
    required String auctionId,
    required String buyerId,
    required String buyerName,
  }) async {
    final auctionRef = _firestore.collection('auctions').doc(auctionId);
    final bidsRef = auctionRef.collection('bids');

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
        throw FirebaseException(plugin: 'firestore', code: 'not-found', message: 'Auction not found');
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