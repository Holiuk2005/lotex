import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/services/category_seed_service.dart';

class CategoryI18n {
  static String keyForId(String categoryId) => 'cat_$categoryId';

  static String label(
    LotexLanguage lang,
    String categoryId, {
    String? fallback,
  }) {
    final key = keyForId(categoryId);
    final tr = LotexI18n.tr(lang, key);
    if (tr != key) return tr;

    if (fallback != null && fallback.trim().isNotEmpty) return fallback;

    final hit = CategorySeedService.categories
        .where((c) => c.id == categoryId)
        .toList(growable: false);
    return hit.isEmpty ? categoryId : hit.first.name;
  }

  static List<CategoryModel> roots(List<CategoryModel> all) {
    return all.where((c) => c.parentId == null).toList(growable: false);
  }

  static List<CategoryModel> childrenOf(List<CategoryModel> all, String parentId) {
    return all.where((c) => c.parentId == parentId).toList(growable: false);
  }
}
