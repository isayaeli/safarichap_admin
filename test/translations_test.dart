import 'package:flutter_test/flutter_test.dart';
import 'package:safarichap_admin/src/core/resources/translations/sw.dart';

void main() {
  final placeholder = RegExp(r'@\w+');
  Set<String> params(String s) =>
      placeholder.allMatches(s).map((m) => m.group(0)!).toSet();

  test('every Kiswahili string is filled in', () {
    for (final entry in sw.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('Kiswahili strings keep the same @placeholders as the English key', () {
    for (final entry in sw.entries) {
      expect(params(entry.value), params(entry.key), reason: entry.key);
    }
  });
}
