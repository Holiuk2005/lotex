import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared ticker to trigger UI updates that depend on current time.
///
/// Used for countdown timers on cards so they update in real time without
/// creating a Timer per widget.
final nowTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});
