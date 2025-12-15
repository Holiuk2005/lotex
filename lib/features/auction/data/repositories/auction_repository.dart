import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auction_entity.dart';

final auctionRepositoryProvider = Provider((ref) => AuctionRepository());

class AuctionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuctionRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required Object imageFile,
    required String sellerId,
  }) async {
    final docRef = _firestore.collection('auctions').doc();
    final auctionId = docRef.id;

    // Upload image
    final storageRef = _storage.ref().child('auctions/$auctionId.jpg');
    if (kIsWeb) {
      // imageFile expected to be XFile or Uint8List on web
      Uint8List bytes;
      if (imageFile is Uint8List) {
        bytes = imageFile;
      } else if (imageFile is List<int>) {
        bytes = Uint8List.fromList(imageFile);
      } else {
        // try XFile
        try {
          // avoid importing image_picker here; use dynamic call
          final dynamic file = imageFile;
          bytes = await file.readAsBytes();
        } catch (e) {
          throw Exception('Unsupported image type for web: $e');
        }
      }
      final uploadTask = await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final imageUrl = await uploadTask.ref.getDownloadURL();

      final auction = AuctionEntity(
        id: auctionId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        startPrice: startPrice,
        currentPrice: startPrice,
        endDate: endDate,
        sellerId: sellerId,
      );

      await docRef.set(auction.toDocument());
      return;
    } else {
      // Mobile: accept File or XFile
      File fileToUpload;
      if (imageFile is File) {
        fileToUpload = imageFile;
      } else {
        final dynamic f = imageFile;
        fileToUpload = File(f.path);
      }

      final uploadTask = await storageRef.putFile(fileToUpload);
      final imageUrl = await uploadTask.ref.getDownloadURL();

    final auction = AuctionEntity(
      id: auctionId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      startPrice: startPrice,
      currentPrice: startPrice,
      endDate: endDate,
      sellerId: sellerId,
    );

    await docRef.set(auction.toDocument());
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