import 'currency.dart';
import 'money.dart';

/// An exchange rate expressed as a rational number of [to] major units per
/// one [from] major unit: `numerator / denominator`.
///
/// Rates are applied once, when a goal is created (currency lock).
class FxRate {
  const FxRate({
    required this.from,
    required this.to,
    required this.numerator,
    required this.denominator,
  }) : assert(denominator > 0);

  const FxRate.identity(Currency c)
    : from = c,
      to = c,
      numerator = 1,
      denominator = 1;

  final Currency from;
  final Currency to;
  final int numerator;
  final int denominator;

  /// Converts [amount] (in [from]) to [to], rounding up to the nearest
  /// minor unit of the target currency.
  Money convert(Money amount) {
    if (amount.currency != from) {
      throw ArgumentError(
        'Rate is for ${from.code}, got ${amount.currency.code}',
      );
    }
    if (from == to) return amount;
    final num =
        BigInt.from(amount.minor) *
        BigInt.from(numerator) *
        BigInt.from(to.minorPerMajor);
    final den = BigInt.from(denominator) * BigInt.from(from.minorPerMajor);
    final result = (num + den - BigInt.one) ~/ den;
    return Money(result.toInt(), to);
  }

  factory FxRate.fromJson(Map<String, dynamic> json) => FxRate(
    from: Currency.fromCode(json['from'] as String),
    to: Currency.fromCode(json['to'] as String),
    numerator: (json['numerator'] as num).toInt(),
    denominator: (json['denominator'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'from': from.code,
    'to': to.code,
    'numerator': numerator,
    'denominator': denominator,
  };
}
