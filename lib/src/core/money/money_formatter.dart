import 'package:intl/intl.dart';

import 'currency.dart';
import 'money.dart';

/// Formats [Money] for display. Formatting is the only place where minor
/// units are divided into major units, and the result is a string — never a
/// value used for further arithmetic.
class MoneyFormatter {
  MoneyFormatter._();

  static final Map<Currency, NumberFormat> _cache = {};
  static final Map<Currency, NumberFormat> _compactCache = {};

  static NumberFormat _formatFor(Currency c) => _cache.putIfAbsent(
    c,
    () => NumberFormat.currency(
      locale: 'en_US',
      name: c.code,
      symbol: '${c.symbol} ',
      decimalDigits: c.decimals,
    ),
  );

  static String format(Money money) =>
      _formatFor(money.currency).format(_toMajor(money));

  /// Short form for tight spaces, e.g. "TSh 1.2M".
  static String compact(Money money) => _compactCache
      .putIfAbsent(
        money.currency,
        () => NumberFormat.compactCurrency(
          locale: 'en_US',
          symbol: '${money.currency.symbol} ',
          decimalDigits: money.currency.decimals == 0 ? 0 : 1,
        ),
      )
      .format(_toMajor(money));

  /// Parses user input (major units, e.g. "150.50") into [Money].
  /// Returns null for invalid input. Done on the string to avoid float error.
  static Money? parse(String input, Currency currency) {
    final cleaned = input.replaceAll(RegExp(r'[,\s]'), '');
    if (cleaned.isEmpty) return null;
    final match = RegExp(r'^(\d+)(?:\.(\d*))?$').firstMatch(cleaned);
    if (match == null) return null;
    final whole = int.parse(match.group(1)!);
    var fraction = match.group(2) ?? '';
    if (fraction.length > currency.decimals) return null;
    fraction = fraction.padRight(currency.decimals, '0');
    final fractionMinor = fraction.isEmpty ? 0 : int.parse(fraction);
    return Money(whole * currency.minorPerMajor + fractionMinor, currency);
  }

  /// Plain major-unit text for an input field ("150.50", "480000"); the
  /// inverse of [parse]. Built from integers, no floating point.
  static String toInput(Money money) {
    final c = money.currency;
    if (c.decimals == 0) return '${money.minor}';
    final major = money.minor ~/ c.minorPerMajor;
    final fraction = (money.minor % c.minorPerMajor).toString().padLeft(
      c.decimals,
      '0',
    );
    return '$major.$fraction';
  }

  // `num` is only used to hand the value to intl for display.
  static num _toMajor(Money m) =>
      m.currency.decimals == 0 ? m.minor : m.minor / m.currency.minorPerMajor;
}

extension MoneyDisplay on Money {
  String get formatted => MoneyFormatter.format(this);
  String get compact => MoneyFormatter.compact(this);

  /// Never shows a negative balance (overpaid goals read as zero).
  String get formattedOrZero =>
      MoneyFormatter.format(isNegative ? Money.zero(currency) : this);
}
