import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
import 'package:safarichap_admin/src/routes/app_routes.dart';

import 'kyc_controller.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _controller = Get.put(KycController(sl()));
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<KycController>();
    super.dispose();
  }

  Future<void> _approve(KycDocument doc) async {
    final ok = await confirmAction(
      title: "Approve ID?".tr,
      message:
          "@name's @type @number will be marked verified and they'll be notified."
              .trParams({
                'name': doc.user.displayName,
                'type': doc.document_type.label,
                'number': doc.document_number,
              }),
      confirmLabel: "Approve".tr,
    );
    if (ok != null) _controller.review(doc, approve: true);
  }

  Future<void> _reject(KycDocument doc) async {
    final note = await confirmAction(
      title: "Reject ID?".tr,
      message: "The customer is asked to submit their document again.".tr,
      confirmLabel: "Reject".tr,
      destructive: true,
      reasonLabel: "Message to the customer".tr,
      reasonRequired: true,
    );
    if (note != null) _controller.review(doc, approve: false, note: note);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<KycDocument>(
        controller: _controller,
        searchHint: 'Customer name, phone or email',
        emptyMessage: 'No documents to review',
        onTap: (d) => _shell.open(AppRoutes.customer(d.user.uuid)),
        filters: [
          FilterDropdown<String>(
            label: 'Status',
            value: _controller.filters['status'],
            options: {
              for (final s in KycStatus.values.where(
                (s) => s != KycStatus.notRequired,
              ))
                s.wire: s.label,
            },
            onChanged: (v) => _controller.setFilter('status', v),
          ),
          FilterDropdown<String>(
            label: 'Document',
            value: _controller.filters['document_type'],
            options: {for (final t in KycDocumentType.values) t.wire: t.label},
            onChanged: (v) => _controller.setFilter('document_type', v),
          ),
        ],
        columns: [
          TableColumn(
            'Customer',
            (d) => TwoLineCell(
              d.user.displayName,
              d.user.phone_number ?? d.user.email,
            ),
            size: ColumnSize.L,
          ),
          TableColumn(
            'Document',
            (d) => Text(d.document_type.label),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Number',
            (d) => SelectableText(
              d.document_number,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          TableColumn(
            'Status',
            (d) => StatusChip.kyc(d.status),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Submitted',
            (d) => Text(TimeUtil.formatDateTime(d.created_at)),
            sortKey: 'created_at',
          ),
          TableColumn(
            'Note',
            (d) => Text(
              d.review_note.isEmpty ? '-' : d.review_note,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TableColumn(
            '',
            (d) => d.status != KycStatus.pending
                ? Text(
                    d.reviewed_by ?? '',
                    style: const TextStyle(fontSize: 12),
                  )
                : PermissionGate(
                    code: 'kyc.review',
                    child: _controller.reviewing.value == d.uuid
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: "Approve".tr,
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () => _approve(d),
                              ),
                              IconButton(
                                tooltip: "Reject".tr,
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () => _reject(d),
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
