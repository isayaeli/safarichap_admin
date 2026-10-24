/// Supported currencies.
///
/// [decimals] is the number of minor-unit digits used when storing amounts.
/// TZS is stored in whole shillings (no minor unit in practice).
enum Currency {
  tzs('TZS', 0, 'TSh'),
  usd('USD', 2, r'$'),
  eur('EUR', 2, '€'),
  gbp('GBP', 2, '£');

  const Currency(this.code, this.decimals, this.symbol);

  final String code;
  final int decimals;
  final String symbol;

  /// Number of minor units in one major unit (1 for TZS, 100 for USD).
  int get minorPerMajor {
    var factor = 1;
    for (var i = 0; i < decimals; i++) {
      factor *= 10;
    }
    return factor;
  }

  /// Whether this currency is paid with mobile money (vs. card).
  bool get isMobileMoney => this == Currency.tzs;

  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code == code.toUpperCase(),
    orElse: () => throw ArgumentError('Unsupported currency: $code'),
  );
}
