import 'package:flutter_test/flutter_test.dart';
import 'package:lotex/services/category_seed_service.dart';
import 'package:firebase_core/firebase_core.dart' as fb;

void main() {
  test('seed categories', () async {
    // Skip seeding when no Firebase app is available (e.g., local dev without emulators).
    try {
      fb.Firebase.app();
    } catch (_) {
      return; // Skip test when Firebase isn't initialized.
    }

    await CategorySeedService.seedCategories();
  }, timeout: Timeout(Duration(minutes: 2)));
}
