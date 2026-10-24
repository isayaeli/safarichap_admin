import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/st/st.dart';

import '../catalogue_controller.dart';
import 'operator_dialog.dart';

class OperatorsScreen extends StatefulWidget {
  const OperatorsScreen({super.key});

  @override
  State<OperatorsScreen> createState() => _OperatorsScreenState();
}

class _OperatorsScreenState extends State<OperatorsScreen> {
  final _controller = Get.put(
    CatalogueController<Operator>(
      sl(),
      CatalogueRepository.operators,
      Operator.fromJson,
    ),
    tag: CatalogueRepository.operators,
  );

  @override
  void dispose() {
    Get.delete<CatalogueController<Operator>>(
      tag: CatalogueRepository.operators,
    );
    super.dispose();
  }

  void _edit([Operator? operator]) {
    if (!can('catalogue.manage')) return;
    Get.dialog(OperatorDialog(controller: _controller, operator: operator));
  }

  Future<void> _delete(Operator o) async {
    final ok = await confirmAction(
      title: "Delete operator?".tr,
      message: "@name is removed. Operators with trips can't be deleted."
          .trParams({'name': o.name}),
      confirmLabel: "Delete".tr,
      destructive: true,
    );
    if (ok != null) _controller.delete(o.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return PagedTable<Operator>(
      controller: _controller,
      searchHint: 'Name, email or phone',
      emptyMessage: 'No operators yet',
      onTap: _edit,
      actions: [
        PermissionGate(
          code: 'catalogue.manage',
          child: FilledButton.icon(
            onPressed: _edit,
            icon: const Icon(Icons.add, size: 18),
            label: Text("New operator".tr),
          ),
        ),
      ],
      columns: [
        TableColumn(
          'Name',
          (o) =>
              Text(o.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          size: ColumnSize.L,
          sortKey: 'name',
        ),
        TableColumn(
          'Phone',
          (o) => Text(o.phone_number.isEmpty ? '-' : o.phone_number),
        ),
        TableColumn(
          'Email',
          (o) => Text(o.email.isEmpty ? '-' : o.email),
          size: ColumnSize.L,
        ),
        TableColumn(
          'Lead time',
          (o) => Text(
            o.lead_time_days == null
                ? "Default".tr
                : "@n days".trParams({'n': '${o.lead_time_days}'}),
          ),
          size: ColumnSize.S,
        ),
        TableColumn(
          'Refund policy',
          (o) => Text(o.refund_policy_name ?? "Default".tr),
        ),
        TableColumn(
          'Trips',
          (o) => Text('${o.itineraries_count}'),
          numeric: true,
          size: ColumnSize.S,
          sortKey: 'itineraries_count',
        ),
        TableColumn(
          '',
          (o) => PermissionGate(
            code: 'catalogue.manage',
            child: IconButton(
              tooltip: "Delete".tr,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(o),
            ),
          ),
          fixedWidth: 60,
        ),
      ],
    );
  }
}
