import 'package:flutter_test/flutter_test.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/fx_rate.dart';
import 'package:safarichap_admin/src/core/money/money.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';

void main() {
  group('Money', () {
    test('stores minor units per currency', () {
      expect(Money.major(150, Currency.usd).minor, 15000);
      expect(Money.major(5000, Currency.tzs).minor, 5000);
    });

    test('rejects mixed-currency arithmetic', () {
      expect(
        () => Money(1, Currency.usd) + Money(1, Currency.tzs),
        throwsArgumentError,
      );
    });

    test('multiplyByRate rounds up to the next minor unit', () {
      // 1.15 × $10.01 = $11.5115 → $11.52
      expect(Money(1001, Currency.usd).multiplyByRate(115, 100).minor, 1152);
    });
  });

  group('MoneyFormatter.parse', () {
    test('parses without floating point error', () {
      expect(MoneyFormatter.parse('0.29', Currency.usd)!.minor, 29);
      expect(MoneyFormatter.parse('1,250.5', Currency.usd)!.minor, 125050);
      expect(MoneyFormatter.parse('250,000', Currency.tzs)!.minor, 250000);
    });

    test('rejects too many decimals and junk', () {
      expect(MoneyFormatter.parse('1.234', Currency.usd), isNull);
      expect(MoneyFormatter.parse('10.5', Currency.tzs), isNull);
      expect(MoneyFormatter.parse('abc', Currency.usd), isNull);
    });
  });

  group('FxRate', () {
    test('converts USD → TZS across minor-unit scales', () {
      const rate = FxRate(
        from: Currency.usd,
        to: Currency.tzs,
        numerator: 2600,
        denominator: 1,
      );
      expect(rate.convert(Money(128000, Currency.usd)).minor, 3328000);
    });

    test('converts TZS → USD and rounds up', () {
      const rate = FxRate(
        from: Currency.tzs,
        to: Currency.usd,
        numerator: 1,
        denominator: 2600,
      );
      // TSh 1,000 = $0.3846… → 39 cents
      expect(rate.convert(Money(1000, Currency.tzs)).minor, 39);
    });
  });
}
