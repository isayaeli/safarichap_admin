import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/payment/payment.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'payment_details_screen.dart';
import 'payments_controller.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _controller = Get.put(PaymentsController(sl()));
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<PaymentsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<AdminPayment>(
        controller: _controller,
        searchHint: 'Reference, receipt, phone or customer',
        emptyMessage: 'No payments match',
        minWidth: 740,
        onTap: (p) async {
          await _shell.open(PaymentDetailsScreen(uuid: p.uuid));
          _controller.load();
        },
        filters: [
          FilterDropdown<String>(
            label: 'Status',
            value: _controller.filters['status'],
            options: {for (final s in PaymentStatus.values) s.wire: s.label},
            onChanged: (v) => _controller.setFilter('status', v),
          ),
          FilterDropdown<String>(
            label: 'Method',
            value: _controller.filters['method'],
            options: {for (final m in PaymentMethod.values) m.wire: m.label},
            onChanged: (v) => _controller.setFilter('method', v),
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
            'Date',
            (p) => Text(TimeUtil.formatDateTime(p.created_at)),
            sortKey: 'created_at',
          ),
          TableColumn(
            'Customer',
            (p) => TwoLineCell(
              p.user.displayName,
              p.phone_number ?? p.user.phone_number,
            ),
          ),
          TableColumn(
            'Goal',
            (p) => Text(p.goal_title, overflow: TextOverflow.ellipsis),
          ),
          TableColumn(
            'Amount',
            (p) => Text(
              p.money.formatted,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            numeric: true,
            sortKey: 'amount',
          ),
          TableColumn(
            'Status',
            (p) => StatusChip.payment(p.status),
            fixedWidth: 110, // keeps the chip on one line
          ),
          // Method and receipt share a column so the table fits without scrolling.
          TableColumn(
            'Method',
            (p) => TwoLineCell(p.method.label, p.receipt_number),
          ),
        ],
      ),
    );
  }
}
