import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safarichap_admin/src/core/components/simple_table.dart';

Future<void> _pump(WidgetTester tester, double width) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: SimpleTable<int>(
            items: const [1, 2],
            headers: const ['Date', 'Amount', 'Status'],
            cells: (i) => [Text('Oct $i'), Text('TZS $i'), const Text('Paid')],
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('fills the available width', (tester) async {
    await _pump(tester, 700);
    expect(tester.getSize(find.byType(Table)).width, 700);
  });

  testWidgets('scrolls instead of overflowing when narrow', (tester) async {
    await _pump(tester, 120);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Table)).width, greaterThan(120));
  });
}
