import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/empty_state.dart';
import 'package:safarichap_admin/src/core/utils/app_config.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';

class TableColumn<T> {
  final String label;
  final Widget Function(T item) cell;
  final ColumnSize size;
  final bool numeric;

  /// DRF `ordering` field; null if the column can't be sorted.
  final String? sortKey;
  final double? fixedWidth;

  const TableColumn(
    this.label,
    this.cell, {
    this.size = ColumnSize.M,
    this.numeric = false,
    this.sortKey,
    this.fixedWidth,
  });
}

/// Full-height list page: toolbar (search, filters, actions), a sortable
/// table bound to a [PagedController], and a pager.
class PagedTable<T> extends StatefulWidget {
  final PagedController<T> controller;
  final List<TableColumn<T>> columns;
  final void Function(T item)? onTap;
  final String searchHint;
  final bool searchable;
  final List<Widget> filters;
  final List<Widget> actions;
  final String emptyMessage;
  final double minWidth;

  const PagedTable({
    super.key,
    required this.controller,
    required this.columns,
    this.onTap,
    this.searchHint = 'Search',
    this.searchable = true,
    this.filters = const [],
    this.actions = const [],
    this.emptyMessage = 'Nothing here yet',
    this.minWidth = 900,
  });

  @override
  State<PagedTable<T>> createState() => _PagedTableState<T>();
}

class _PagedTableState<T> extends State<PagedTable<T>> {
  late final _search = TextEditingController(
    text: widget.controller.search.value,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  int? get _sortIndex {
    final ordering = widget.controller.ordering.value;
    if (ordering == null) return null;
    final key = ordering.replaceFirst('-', '');
    final i = widget.columns.indexWhere((c) => c.sortKey == key);
    return i < 0 ? null : i;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (widget.searchable)
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: _search,
                        onChanged: c.setSearch,
                        decoration: InputDecoration(
                          hintText: widget.searchHint.tr,
                          prefixIcon: const Icon(Icons.search, size: 20),
                        ),
                      ),
                    ),
                  ...widget.filters,
                  IconButton(
                    tooltip: "Refresh".tr,
                    onPressed: () => c.load(),
                    icon: const Icon(Icons.refresh),
                  ),
                  ...widget.actions,
                ],
              ),
            ),
            Obx(
              () => SizedBox(
                height: 2,
                child: c.isLoading.value
                    ? const LinearProgressIndicator()
                    : null,
              ),
            ),
            Expanded(
              child: Obx(() {
                final items = c.items.toList();
                final sortIndex = _sortIndex;
                return DataTable2(
                  minWidth: widget.minWidth,
                  columnSpacing: 16,
                  horizontalMargin: 16,
                  headingRowHeight: 44,
                  dataRowHeight: 56,
                  showCheckboxColumn: false,
                  sortColumnIndex: sortIndex,
                  sortAscending: !(c.ordering.value?.startsWith('-') ?? false),
                  headingRowColor: WidgetStatePropertyAll(
                    scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ),
                  empty: c.isLoading.value
                      ? const SizedBox.shrink()
                      : SmallEmptyState(message: widget.emptyMessage.tr),
                  columns: [
                    for (final col in widget.columns)
                      DataColumn2(
                        label: Text(col.label.tr),
                        size: col.size,
                        numeric: col.numeric,
                        fixedWidth: col.fixedWidth,
                        onSort: col.sortKey == null
                            ? null
                            : (_, ascending) => c.setOrdering(
                                ascending ? col.sortKey : '-${col.sortKey}',
                              ),
                      ),
                  ],
                  rows: [
                    for (final item in items)
                      DataRow2(
                        onTap: widget.onTap == null
                            ? null
                            : () => widget.onTap!(item),
                        cells: [
                          for (final col in widget.columns)
                            DataCell(col.cell(item)),
                        ],
                      ),
                  ],
                );
              }),
            ),
            const Divider(height: 1),
            Obx(() {
              final from = c.count.value == 0
                  ? 0
                  : (c.page.value - 1) * AppConfig.pageSize + 1;
              final to = (c.page.value * AppConfig.pageSize).clamp(
                0,
                c.count.value,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "@from–@to of @count".trParams({
                        'from': '$from',
                        'to': '$to',
                        'count': '${c.count.value}',
                      }),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "Previous page".tr,
                      onPressed: c.page.value > 1
                          ? () => c.load(toPage: c.page.value - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: "Next page".tr,
                      onPressed: c.page.value < c.pageCount
                          ? () => c.load(toPage: c.page.value + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Compact dropdown for a table filter; the first option clears it.
class FilterDropdown<V> extends StatelessWidget {
  final String label;
  final V? value;
  final Map<V, String> options;
  final ValueChanged<V?> onChanged;
  final double width;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 170,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<V?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label.tr),
        items: [
          DropdownMenuItem<V?>(value: null, child: Text("All".tr)),
          for (final e in options.entries)
            DropdownMenuItem<V?>(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Primary text with a muted second line, for table cells.
class TwoLineCell extends StatelessWidget {
  final String title;
  final String? subtitle;
  const TwoLineCell(this.title, [this.subtitle, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Text(
            subtitle!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
