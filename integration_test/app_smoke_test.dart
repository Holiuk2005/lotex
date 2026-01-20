import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lotex/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts (smoke)', (tester) async {
    app.main();

    // Give the app time to initialize (Firebase, routing, etc.)
    await tester.pumpAndSettle(const Duration(seconds: 10));

    expect(tester.takeException(), isNull);
  });
}
