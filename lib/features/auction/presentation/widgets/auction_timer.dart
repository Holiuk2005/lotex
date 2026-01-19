import 'dart:async';

import 'package:flutter/widgets.dart';

/// A lightweight countdown widget that updates itself once per [tick].
///
/// Goal: keep parent widgets (images/streams) stable while the countdown ticks.
class AuctionTimer extends StatefulWidget {
  final DateTime endTime;
  final Duration tick;
  final Widget Function(BuildContext context, Duration timeLeft) builder;

  const AuctionTimer({
    super.key,
    required this.endTime,
    required this.builder,
    this.tick = const Duration(seconds: 1),
  });

  @override
  State<AuctionTimer> createState() => _AuctionTimerState();
}

class _AuctionTimerState extends State<AuctionTimer> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recompute();
    _timer = Timer.periodic(widget.tick, (_) => _recompute());
  }

  @override
  void didUpdateWidget(covariant AuctionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.endTime != widget.endTime) {
      _recompute();
    }

    if (oldWidget.tick != widget.tick) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.tick, (_) => _recompute());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _recompute() {
    final diff = widget.endTime.difference(DateTime.now());
    final next = diff.isNegative ? Duration.zero : diff;

    if (!mounted) return;
    if (next == _timeLeft) return;

    setState(() {
      _timeLeft = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _timeLeft);
  }
}
