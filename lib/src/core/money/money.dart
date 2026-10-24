import 'currency.dart';

/// An immutable amount of money stored as integer minor units.
///
/// Never use `double` for money. All arithmetic stays in integers; the only
/// place fractional values appear is [multiplyByRate], which rounds up
/// explicitly and is used for season multipliers / FX at goal creation time.
class Money implements Comparable<Money> {
  const Money(this.minor, this.currency);

  const Money.zero(this.currency) : minor = 0;

  /// Builds from whole major units, e.g. `Money.major(150, Currency.usd)`
  /// is $150.00 (15000 minor units).
  factory Money.major(int major, Currency currency) =>
      Money(major * currency.minorPerMajor, currency);

  final int minor;
  final Currency currency;

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;
  bool get isPositive => minor > 0;

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minor + other.minor, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minor - other.minor, currency);
  }

  Money operator *(int factor) => Money(minor * factor, currency);

  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;
  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;

  /// Multiplies by a rate expressed as a rational `numerator / denominator`
  /// and rounds up to the nearest minor unit. Using a rational keeps the
  /// computation exact (e.g. multiplier 1.15 → 115/100).
  Money multiplyByRate(int numerator, int denominator) {
    assert(denominator > 0);
    final product = minor * numerator;
    final result = (product + denominator - 1) ~/ denominator;
    return Money(result, currency);
  }

  Money clampMin(Money floor) => this < floor ? floor : this;

  static Money max(Money a, Money b) => a >= b ? a : b;
  static Money min(Money a, Money b) => a <= b ? a : b;

  static Money sum(Iterable<Money> values, Currency currency) =>
      values.fold(Money.zero(currency), (acc, m) => acc + m);

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Currency mismatch: ${currency.code} vs ${other.currency.code}',
      );
    }
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minor.compareTo(other.minor);
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() => '${currency.code} $minor (minor)';

  Map<String, dynamic> toJson() => {'amount': minor, 'currency': currency.code};

  factory Money.fromJson(Map<String, dynamic> json) => Money(
    (json['amount'] as num).toInt(),
    Currency.fromCode(json['currency'] as String),
  );
}
