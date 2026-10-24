import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'sw.dart';

/// English is the key itself, so only Kiswahili needs a map.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_US': {}, 'sw_TZ': sw};
}

/// timeago ships no Kiswahili. Only past times are shown ("x ago"), so the
/// agreeing "-liopita" suffix is part of each phrase.
class SwahiliTimeagoMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'sasa hivi';
  @override
  String aboutAMinute(int minutes) => 'dakika moja iliyopita';
  @override
  String minutes(int minutes) => 'dakika $minutes zilizopita';
  @override
  String aboutAnHour(int minutes) => 'takriban saa moja iliyopita';
  @override
  String hours(int hours) => 'saa $hours zilizopita';
  @override
  String aDay(int hours) => 'siku moja iliyopita';
  @override
  String days(int days) => 'siku $days zilizopita';
  @override
  String aboutAMonth(int days) => 'takriban mwezi mmoja uliopita';
  @override
  String months(int months) => 'miezi $months iliyopita';
  @override
  String aboutAYear(int year) => 'takriban mwaka mmoja uliopita';
  @override
  String years(int years) => 'miaka $years iliyopita';
  @override
  String wordSeparator() => ' ';
}
