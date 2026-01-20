import 'package:flutter_test/flutter_test.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/currency.dart';

void main() {
  test('default decimal digits', () {
    expect(LotexCurrency.defaultDecimalDigits(LotexCurrency.uah), 0);
    expect(LotexCurrency.defaultDecimalDigits(LotexCurrency.usd), 2);
    expect(LotexCurrency.defaultDecimalDigits(LotexCurrency.eur), 2);
  });

  test('formatter is cached (same instance)', () {
    LotexCurrency.maxCachedFormatters = 50;
    final a = LotexCurrency.formatter(localeName: 'en_US', code: LotexCurrency.usd);
    final b = LotexCurrency.formatter(localeName: 'en_US', code: LotexCurrency.usd);
    expect(identical(a, b), isTrue);
  });

  test('formatCurrency uses correct symbols', () {
    final usd = LotexI18n.formatCurrency(12.3, LotexLanguage.en, currency: LotexCurrency.usd);
    final eur = LotexI18n.formatCurrency(12.3, LotexLanguage.en, currency: LotexCurrency.eur);
    final uah = LotexI18n.formatCurrency(12, LotexLanguage.uk, currency: LotexCurrency.uah);

    expect(usd.contains(r'$'), isTrue);
    expect(eur.contains('€'), isTrue);
    expect(uah.contains('₴'), isTrue);
  });
}
