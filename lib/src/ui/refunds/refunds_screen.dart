import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/payment/payment.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/goals/goal_details_screen.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'refunds_controller.dart';

class RefundsScreen extends StatefulWidget {
  const RefundsScreen({super.key});

  @override
  State<RefundsScreen> createState() => _RefundsScreenState();
}

class _RefundsScreenState extends State<RefundsScreen> {
  final _controller = Get.put(RefundsController(sl()));
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<RefundsController>();
    super.dispose();
  }

  Future<void> _process(AdminRefund r) async {
    final ok = await confirmAction(
      title: "Send refund now?".tr,
      message: r.currency == 'TZS'
          ? "@amount goes to @phone by mobile money.".trParams({
              'amount': r.money.formatted,
              'phone': r.phone_number ?? '-',
            })
          : "@amount is refunded to the customer's card.".trParams({
              'amount': r.money.formatted,
            }),
      confirmLabel: "Send".tr,
    );
    if (ok != null) _controller.process(r);
  }

  Future<void> _markCompleted(AdminRefund r) async {
    final reference = await promptText(
      title: "Mark as paid out".tr,
      message:
          "Use this only after you've paid @amount by hand (bank transfer, cash)."
              .trParams({'amount': r.money.formatted}),
      label: "Payout reference".tr,
      confirmLabel: "Mark completed".tr,
    );
    if (reference != null) _controller.markCompleted(r, reference);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<AdminRefund>(
        controller: _controller,
        searchHint: 'Reference, phone, customer or goal',
        emptyMessage: 'No refunds match',
        minWidth: 1050,
        onTap: (r) => _shell.open(GoalDetailsScreen(uuid: r.goal_uuid)),
        filters: [
          FilterDropdown<String>(
            label: 'Status',
            value: _controller.filters['status'],
            options: {for (final s in RefundStatus.values) s.wire: s.label},
            onChanged: (v) => _controller.setFilter('status', v),
          ),
        ],
        columns: [
          TableColumn(
            'Created',
            (r) => Text(TimeUtil.formatDateTime(r.created_at)),
            sortKey: 'created_at',
          ),
          TableColumn(
            'Customer',
            (r) => TwoLineCell(r.user.displayName, r.phone_number),
            size: ColumnSize.L,
          ),
          TableColumn(
            'Goal',
            (r) => Text(r.goal_title, overflow: TextOverflow.ellipsis),
            size: ColumnSize.L,
          ),
          TableColumn(
            'Amount',
            (r) => Text(
              r.money.formatted,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            numeric: true,
            sortKey: 'amount',
          ),
          TableColumn(
            'Status',
            (r) => StatusChip.refund(r.status),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Attempts',
            (r) => Text('${r.attempts}'),
            size: ColumnSize.S,
            numeric: true,
          ),
          TableColumn(
            'Last error',
            (r) => Tooltip(
              message: r.failure_reason ?? '',
              child: Text(
                r.failure_reason ?? '-',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          TableColumn(
            '',
            (r) => !r.status.canProcess
                ? Text(
                    r.provider_reference ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  )
                : PermissionGate(
                    code: 'refunds.manage',
                    child: _controller.working.value == r.uuid
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Send now".tr,
                                icon: const Icon(Icons.send_outlined),
                                onPressed: () => _process(r),
                              ),
                              IconButton(
                                tooltip: "Mark as paid out".tr,
                                icon: const Icon(Icons.task_alt),
                                onPressed: () => _markCompleted(r),
                              ),
                            ],
                          ),
                  ),
            fixedWidth: 120,
          ),
        ],
      ),
    );
  }
}
