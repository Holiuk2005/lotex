import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/marketplace_item_entity.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class MarketplaceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Stream<MarketplaceItemEntity> watchItem(String id) {
    return _db.collection('marketplace_items').doc(id).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Item not found');
      return MarketplaceItemEntity.fromDocument(doc);
    });
  }

  Future<void> createItem({
    required String title,
    required String description,
    required String category,
    required String currency,
    required double price,
    required String sellerId,
    required XFile image,
  }) async {
    final id = _uuid.v4();
    String imageUrl = '';
    
    // Upload image
    final ext = image.name.split('.').last.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final fileName = '$id.${ext.isEmpty ? 'jpg' : ext}';
    final ref = _storage.ref().child('marketplace_images').child(fileName);
    
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/${ext.isEmpty ? 'jpeg' : ext}'));
    } else {
      await ref.putFile(File(image.path), SettableMetadata(contentType: 'image/${ext.isEmpty ? 'jpeg' : ext}'));
    }
    imageUrl = await ref.getDownloadURL();

    final item = MarketplaceItemEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      category: category,
      currency: currency,
      price: price,
      sellerId: sellerId,
      status: 'active',
      createdAt: DateTime.now(),
    );

    await _db.collection('marketplace_items').doc(id).set(item.toDocument());
  }

  Future<void> buyItem({required String itemId, required String buyerId}) async {
    final docRef = _db.collection('marketplace_items').doc(itemId);

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      final data = snap.data();

      if (data == null) {
        throw Exception('Товар не знайдено.');
      }

      final status = (data['status'] as String?) ?? 'active';
      if (status != 'active') {
        throw Exception('Цей товар вже продано або недоступний.');
      }

      final sellerId = (data['sellerId'] as String?) ?? '';
      if (sellerId.isNotEmpty && sellerId == buyerId) {
        throw Exception('Продавець не може купити власний товар.');
      }

      transaction.update(docRef, {
        'status': 'sold',
        'winnerId': buyerId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
