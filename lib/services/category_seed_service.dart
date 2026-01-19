import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String? parentId;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'parentId': parentId,
    };
  }
}

class CategorySeedService {
  static const String collectionName = 'categories';

  static const List<CategoryModel> categories = [
    // Root categories
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      slug: 'transport',
      icon: 'directions_car',
      parentId: null,
    ),
    CategoryModel(
      id: 'real_estate',
      name: 'Real Estate',
      slug: 'real-estate',
      icon: 'home',
      parentId: null,
    ),
    CategoryModel(
      id: 'electronics',
      name: 'Electronics',
      slug: 'electronics',
      icon: 'devices',
      parentId: null,
    ),
    CategoryModel(
      id: 'home_garden',
      name: 'Home & Garden',
      slug: 'home-garden',
      icon: 'deck',
      parentId: null,
    ),
    CategoryModel(
      id: 'fashion',
      name: 'Fashion',
      slug: 'fashion',
      icon: 'checkroom',
      parentId: null,
    ),
    CategoryModel(
      id: 'kids',
      name: 'Kids',
      slug: 'kids',
      icon: 'child_care',
      parentId: null,
    ),
    CategoryModel(
      id: 'hobbies',
      name: 'Hobbies',
      slug: 'hobbies',
      icon: 'sports_soccer',
      parentId: null,
    ),
    CategoryModel(
      id: 'animals',
      name: 'Animals',
      slug: 'animals',
      icon: 'pets',
      parentId: null,
    ),

    // Transport subcategories
    CategoryModel(
      id: 'cars',
      name: 'Cars',
      slug: 'cars',
      icon: 'directions_car',
      parentId: 'transport',
    ),
    CategoryModel(
      id: 'two_wheeler',
      name: 'Moto',
      slug: 'moto',
      icon: 'two_wheeler',
      parentId: 'transport',
    ),

    // Real Estate subcategories
    CategoryModel(
      id: 'apartments',
      name: 'Apartments',
      slug: 'apartments',
      icon: 'apartment',
      parentId: 'real_estate',
    ),
    CategoryModel(
      id: 'houses',
      name: 'Houses',
      slug: 'houses',
      icon: 'house',
      parentId: 'real_estate',
    ),

    // Electronics subcategories
    CategoryModel(
      id: 'smartphones',
      name: 'Smartphones',
      slug: 'smartphones',
      icon: 'smartphone',
      parentId: 'electronics',
    ),
    CategoryModel(
      id: 'laptops',
      name: 'Laptops',
      slug: 'laptops',
      icon: 'laptop',
      parentId: 'electronics',
    ),

    // Home & Garden subcategories
    CategoryModel(
      id: 'furniture',
      name: 'Furniture',
      slug: 'furniture',
      icon: 'chair',
      parentId: 'home_garden',
    ),
    CategoryModel(
      id: 'decor',
      name: 'Decor',
      slug: 'decor',
      icon: 'format_paint',
      parentId: 'home_garden',
    ),

    // Fashion subcategories
    CategoryModel(
      id: 'mens_clothing',
      name: "Men's Clothing",
      slug: 'mens-clothing',
      icon: 'checkroom',
      parentId: 'fashion',
    ),
    CategoryModel(
      id: 'womens_clothing',
      name: "Women's Clothing",
      slug: 'womens-clothing',
      icon: 'checkroom',
      parentId: 'fashion',
    ),

    // Kids subcategories
    CategoryModel(
      id: 'toys',
      name: 'Toys',
      slug: 'toys',
      icon: 'toys',
      parentId: 'kids',
    ),
    CategoryModel(
      id: 'strollers',
      name: 'Strollers',
      slug: 'strollers',
      icon: 'stroller',
      parentId: 'kids',
    ),

    // Hobbies subcategories
    CategoryModel(
      id: 'sport',
      name: 'Sport',
      slug: 'sport',
      icon: 'sports_soccer',
      parentId: 'hobbies',
    ),
    CategoryModel(
      id: 'music',
      name: 'Music',
      slug: 'music',
      icon: 'music_note',
      parentId: 'hobbies',
    ),

    // Animals subcategories
    CategoryModel(
      id: 'dogs',
      name: 'Dogs',
      slug: 'dogs',
      icon: 'pets',
      parentId: 'animals',
    ),
    CategoryModel(
      id: 'cats',
      name: 'Cats',
      slug: 'cats',
      icon: 'pets',
      parentId: 'animals',
    ),
  ];

  /// Seeds `categories` collection.
  ///
  /// - Uses `WriteBatch` (single commit).
  /// - Uses `SetOptions(merge: true)` so you can safely rerun.
  static Future<void> seedCategories() async {
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      final col = db.collection(collectionName);
      for (final category in categories) {
        batch.set(
          col.doc(category.id),
          category.toMap(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('✅ Seeded categories: ${categories.length}');
    } catch (e, st) {
      debugPrint('❌ Failed to seed categories: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
