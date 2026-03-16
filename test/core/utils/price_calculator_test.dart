import 'package:flutter_test/flutter_test.dart';
import 'package:lotex/core/utils/price_calculator.dart';

void main() {
  group('PriceCalculator', () {
    test('розраховує правильний кошторис при типових значеннях', () {
      final bd = PriceCalculator.calculateBreakdown(1000.0, 50.0);
      expect(bd.subtotal, 1000.0);
      expect(bd.shipping, 50.0);
      expect(bd.serviceFee, closeTo(20.0, 0.001)); // 2% від 1000
      expect(bd.total, closeTo(1070.0, 0.001));
    });

    test('нульова ціна і доставка → нульовий кошторис', () {
      final bd = PriceCalculator.calculateBreakdown(0.0, 0.0);
      expect(bd.subtotal, 0.0);
      expect(bd.shipping, 0.0);
      expect(bd.serviceFee, 0.0);
      expect(bd.total, 0.0);
    });

    test('результат округлюється до 2 знаків після коми', () {
      // 333.33 * 0.02 = 6.6666... → 6.67
      final bd = PriceCalculator.calculateBreakdown(333.33, 0.0);
      expect(bd.serviceFee, 6.67);
      expect(bd.total, 340.0);
    });

    test('serviceFeeRate = 2%', () {
      expect(PriceCalculator.serviceFeeRate, 0.02);
    });

    test('велика ціна — без втрати точності', () {
      final bd = PriceCalculator.calculateBreakdown(99999.99, 0.0);
      expect(bd.serviceFee, closeTo(2000.0, 1.0));
      expect(bd.total, closeTo(101999.99, 1.0));
    });
  });
}
