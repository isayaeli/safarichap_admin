import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Small embedded table for detail pages (a user's goals, a goal's payments).
class SimpleTable<T> extends StatelessWidget {
  final List<T> items;
  final List<String> headers;
  final List<Widget> Function(T item) cells;
  final void Function(T item)? onTap;
  final String emptyMessage;

  const SimpleTable({
    super.key,
    required this.items,
    required this.headers,
    required this.cells,
    this.onTap,
    this.emptyMessage = 'Nothing here yet',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          emptyMessage.tr,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }
    // Fill the card's width; scroll sideways only when the columns don't fit.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            showCheckboxColumn: false,
            headingRowHeight: 38,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 56,
            horizontalMargin: 4,
            columnSpacing: 28,
            columns: [
              for (final h in headers)
                DataColumn(
                  label: Text(h.tr),
                  // flex shares the spare width instead of leaving a blank strip.
                  columnWidth: const IntrinsicColumnWidth(flex: 1),
                ),
            ],
            rows: [
              for (final item in items)
                DataRow(
                  onSelectChanged: onTap == null ? null : (_) => onTap!(item),
                  cells: [for (final c in cells(item)) DataCell(c)],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
