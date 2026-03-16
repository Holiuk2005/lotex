import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Спільний ticker для оновлення UI-віджетів, які залежать від поточного часу.
///
/// Використовується для таймерів зворотного відліку на картках, щоб вони
/// оновлювались в реальному часі без Timer для кожного віджета.
final nowTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});
