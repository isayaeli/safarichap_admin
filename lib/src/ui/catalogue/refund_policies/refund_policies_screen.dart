import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/st/st.dart';

import '../catalogue_controller.dart';
import 'refund_policy_dialog.dart';

/// "61+ days: 90% · 31+: 50% · 0+: 0%"
String tiersSummary(List<RefundTier> tiers) => tiers
    .map(
      (t) => "@days+ days: @pct%".trParams({
        'days': '${t.min_days}',
        'pct': '${t.percentage}',
      }),
    )
    .join(' · ');

class RefundPoliciesScreen extends StatefulWidget {
  const RefundPoliciesScreen({super.key});

  @override
  State<RefundPoliciesScreen> createState() => _RefundPoliciesScreenState();
}

class _RefundPoliciesScreenState extends State<RefundPoliciesScreen> {
  final _controller = Get.put(
    CatalogueController<RefundPolicy>(
      sl(),
      CatalogueRepository.refundPolicies,
      RefundPolicy.fromJson,
    ),
    tag: CatalogueRepository.refundPolicies,
  );

  @override
  void dispose() {
    Get.delete<CatalogueController<RefundPolicy>>(
      tag: CatalogueRepository.refundPolicies,
    );
    super.dispose();
  }

  void _edit([RefundPolicy? p]) {
    if (!can('catalogue.manage')) return;
    Get.dialog(RefundPolicyDialog(controller: _controller, policy: p));
  }

  Future<void> _delete(RefundPolicy p) async {
    final ok = await confirmAction(
      title: "Delete policy?".tr,
      message: "Operators using @name fall back to the default policy."
          .trParams({'name': p.name}),
      confirmLabel: "Delete".tr,
      destructive: true,
    );
    if (ok != null) _controller.delete(p.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return PagedTable<RefundPolicy>(
      controller: _controller,
      emptyMessage:
          'No refund policies yet. Cancellations use the built-in default.',
      onTap: _edit,
      actions: [
        PermissionGate(
          code: 'catalogue.manage',
          child: FilledButton.icon(
            onPressed: _edit,
            icon: const Icon(Icons.add, size: 18),
            label: Text("New policy".tr),
          ),
        ),
      ],
      columns: [
        TableColumn(
          'Name',
          (p) => Row(
            children: [
              Flexible(
                child: Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (p.is_default) ...[
                const SizedBox(width: 8),
                StatusChip(label: "Default".tr, color: Colors.blue),
              ],
            ],
          ),
          sortKey: 'name',
        ),
        TableColumn(
          'Tiers',
          (p) => Text(tiersSummary(p.tiers), overflow: TextOverflow.ellipsis),
          size: ColumnSize.L,
        ),
        TableColumn(
          'Fee',
          (p) => Text('${p.processing_fee_bps / 100}%'),
          size: ColumnSize.S,
        ),
        TableColumn(
          'Operators',
          (p) => Text('${p.operators_count}'),
          numeric: true,
          size: ColumnSize.S,
        ),
        TableColumn(
          '',
          (p) => PermissionGate(
            code: 'catalogue.manage',
            child: IconButton(
              tooltip: "Delete".tr,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(p),
            ),
          ),
          fixedWidth: 60,
        ),
      ],
    );
  }
}
