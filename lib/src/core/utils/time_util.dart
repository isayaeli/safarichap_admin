import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimeUtil {
  TimeUtil._();

  // Built per call so month names follow the current app language.
  static DateFormat get _date => DateFormat('d MMM yyyy');
  static DateFormat get _shortDate => DateFormat('d MMM');
  static DateFormat get _dateTime => DateFormat('d MMM yyyy, HH:mm');

  /// 15 Jan 2027
  static String formatDate(DateTime? date) =>
      date == null ? '-' : _date.format(date.toLocal());

  /// 15 Jan
  static String formatShortDate(DateTime? date) =>
      date == null ? '-' : _shortDate.format(date.toLocal());

  /// 15 Jan 2027, 14:30
  static String formatDateTime(DateTime? date) =>
      date == null ? '-' : _dateTime.format(date.toLocal());

  /// "in 12 days" / "today" / "3 days ago"
  static String relativeDays(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'today'.tr;
    if (diff == 1) return 'tomorrow'.tr;
    if (diff == -1) return 'yesterday'.tr;
    return diff > 0
        ? 'in @count days'.trParams({'count': '$diff'})
        : '@count days ago'.trParams({'count': '${-diff}'});
  }
}
