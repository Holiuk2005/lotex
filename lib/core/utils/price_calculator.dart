import 'package:flutter/foundation.dart';

@immutable
class PriceBreakdown {
  final double subtotal;
  final double shipping;
  final double serviceFee;
  final double total;

  const PriceBreakdown({
    required this.subtotal,
    required this.shipping,
    required this.serviceFee,
    required this.total,
  });
}

class PriceCalculator {
  static const double serviceFeeRate = 0.02;

  static PriceBreakdown calculateBreakdown(double bidAmount, double shippingCost) {
    final subtotal = _round2(bidAmount);
    final shipping = _round2(shippingCost);
    final serviceFee = _round2(subtotal * serviceFeeRate);
    final total = _round2(subtotal + shipping + serviceFee);

    return PriceBreakdown(
      subtotal: subtotal,
      shipping: shipping,
      serviceFee: serviceFee,
      total: total,
    );
  }

  static double _round2(double v) {
    // Avoid floating point artifacts in UI/Firestore.
    return double.parse(v.toStringAsFixed(2));
  }
}
