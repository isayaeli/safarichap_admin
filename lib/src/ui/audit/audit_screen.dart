import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';

import 'audit_controller.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  final _controller = Get.put(AuditController(sl()));

  static const _areas = {
    'user.': 'Customers',
    'kyc.': 'KYC',
    'goal.': 'Goals',
    'payment.': 'Payments',
    'refund.': 'Refunds',
    'booking.': 'Bookings',
    'itinerary.': 'Trips',
    'operator.': 'Operators',
    'destination.': 'Destinations',
    'refund_policy.': 'Refund policies',
    'fx.': 'FX rates',
    'settings.': 'Settings',
    'notification.': 'Notifications',
    'staff.': 'Staff',
    'role.': 'Roles',
  };

  @override
  void dispose() {
    Get.delete<AuditController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<AuditLogEntry>(
        controller: _controller,
        searchHint: 'Action, target or staff member',
        emptyMessage: 'No actions recorded',
        onTap: (e) => Get.dialog(_AuditDetailDialog(entry: e)),
        filters: [
          FilterDropdown<String>(
            label: 'Area',
            value: _controller.filters['action__startswith'],
            options: {for (final e in _areas.entries) e.key: e.value.tr},
            onChanged: (v) => _controller.setFilter('action__startswith', v),
          ),
        ],
        columns: [
          TableColumn(
            'When',
            (e) => Text(TimeUtil.formatDateTime(e.created_at)),
            sortKey: 'created_at',
          ),
          TableColumn(
            'Staff',
            (e) => TwoLineCell(
              e.actor?.displayName ?? "System".tr,
              e.actor?.email,
            ),
          ),
          TableColumn(
            'Action',
            (e) => Text(
              e.action,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
            ),
          ),
          TableColumn(
            'Target',
            (e) => TwoLineCell(
              e.target_label.isEmpty ? e.target_type : e.target_label,
              e.target_type,
            ),
            size: ColumnSize.L,
          ),
          TableColumn(
            'IP',
            (e) =>
                Text(e.ip_address ?? '-', style: const TextStyle(fontSize: 12)),
            size: ColumnSize.S,
          ),
        ],
      ),
    );
  }
}

/// Before/after of the changed fields only.
class _AuditDetailDialog extends StatelessWidget {
  final AuditLogEntry entry;
  const _AuditDetailDialog({required this.entry});

  String _fmt(dynamic v) => v is Map || v is List
      ? const JsonEncoder.withIndent('  ').convert(v)
      : '${v ?? '-'}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final before = entry.before ?? {};
    final after = entry.after ?? {};
    final keys = {
      ...before.keys,
      ...after.keys,
    }.where((k) => jsonEncode(before[k]) != jsonEncode(after[k])).toList();
    final mono = const TextStyle(fontFamily: 'monospace', fontSize: 12);

    return AlertDialog(
      title: Text(
        entry.action,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "@who · @when · @target".trParams({
                  'who': entry.actor?.displayName ?? "System".tr,
                  'when': TimeUtil.formatDateTime(entry.created_at),
                  'target': entry.target_label.isEmpty
                      ? '${entry.target_type} ${entry.target_id}'
                      : entry.target_label,
                }),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (keys.isEmpty)
                Text("No field changes recorded".tr)
              else
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(color: scheme.outlineVariant),
                  ),
                  children: [
                    TableRow(
                      children: [
                        for (final h in ['Field', 'Before', 'After'])
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              h.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final k in keys)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(k, style: mono),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SelectableText(
                              _fmt(before[k]),
                              style: mono.copyWith(color: Colors.red.shade400),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SelectableText(
                              _fmt(after[k]),
                              style: mono.copyWith(
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => closeDialog(), child: Text("Close".tr)),
      ],
    );
  }
}
