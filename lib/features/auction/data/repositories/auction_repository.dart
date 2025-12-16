import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/auction_entity.dart';

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
      final currentPrice = (snapshot.data()?['currentPrice'] as num?)?.toDouble() ?? 0.0;
      final bidCount = (snapshot.data()?['bidCount'] as int?) ?? 0;

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
}