import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'goal_details_screen.dart';
import 'goals_controller.dart';
import 'widgets/goal_progress.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _controller = Get.put(GoalsController(sl()));
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<GoalsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<GoalSummary>(
        controller: _controller,
        searchHint: 'Trip, customer name or phone',
        emptyMessage: 'No goals match',
        minWidth: 1050,
        onTap: (g) async {
          await _shell.open(GoalDetailsScreen(uuid: g.uuid));
          _controller.load();
        },
        filters: [
          FilterDropdown<String>(
            label: 'Status',
            value: _controller.filters['status'],
            options: {for (final s in GoalStatus.values) s.wire: s.label},
            onChanged: (v) => _controller.setFilter('status', v),
          ),
          FilterDropdown<String>(
            label: 'Currency',
            value: _controller.filters['currency'],
            options: {for (final c in Currency.values) c.code: c.code},
            onChanged: (v) => _controller.setFilter('currency', v),
            width: 130,
          ),
        ],
        columns: [
          TableColumn(
            'Trip',
            (g) => TwoLineCell(g.title, g.itinerary_title),
            size: ColumnSize.L,
          ),
          TableColumn(
            'Customer',
            (g) => TwoLineCell(g.user.displayName, g.user.phone_number),
          ),
          TableColumn(
            'Status',
            (g) => StatusChip.goal(g.status),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Progress',
            (g) => GoalProgress(goal: g),
            sortKey: 'amount_paid',
          ),
          TableColumn(
            'Total',
            (g) => Text(g.total.formatted),
            numeric: true,
            sortKey: 'total_amount',
          ),
          TableColumn(
            'Pay by',
            (g) => Text(TimeUtil.formatDate(g.pay_by_date)),
            sortKey: 'pay_by_date',
            size: ColumnSize.S,
          ),
          TableColumn(
            'Travel',
            (g) => Text(TimeUtil.formatDate(g.travel_date)),
            sortKey: 'travel_date',
            size: ColumnSize.S,
          ),
          TableColumn(
            'Created',
            (g) => Text(TimeUtil.formatDate(g.created_at)),
            sortKey: 'created_at',
            size: ColumnSize.S,
          ),
        ],
      ),
    );
  }
}
