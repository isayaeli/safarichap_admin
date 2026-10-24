import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/st/st.dart';

import '../catalogue_controller.dart';

class OperatorDialog extends StatefulWidget {
  final CatalogueController<Operator> controller;
  final Operator? operator;
  const OperatorDialog({super.key, required this.controller, this.operator});

  @override
  State<OperatorDialog> createState() => _OperatorDialogState();
}

class _OperatorDialogState extends State<OperatorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.operator?.name);
  late final _phone = TextEditingController(
    text: widget.operator?.phone_number,
  );
  late final _whatsapp = TextEditingController(text: widget.operator?.whatsapp);
  late final _email = TextEditingController(text: widget.operator?.email);
  late final _lead = TextEditingController(
    text: widget.operator?.lead_time_days?.toString() ?? '',
  );
  late String? _policy = widget.operator?.refund_policy;
  List<RefundPolicy> _policies = [];

  @override
  void initState() {
    super.initState();
    sl<CatalogueRepository>()
        .retrieveAll(CatalogueRepository.refundPolicies, RefundPolicy.fromJson)
        .execute((r) {
          if (r is Success && mounted) {
            setState(() => _policies = r.data as List<RefundPolicy>);
          }
        });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final ok = await widget.controller.save(
      uuid: widget.operator?.uuid,
      body: {
        'name': _name.text.trim(),
        'phone_number': _phone.text.trim(),
        'whatsapp': _whatsapp.text.trim(),
        'email': _email.text.trim(),
        'lead_time_days': int.tryParse(_lead.text.trim()),
        'refund_policy': _policy,
      },
    );
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.operator == null ? "New operator".tr : "Edit operator".tr,
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: "Name".tr),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? "Required".tr : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phone,
                        decoration: InputDecoration(labelText: "Phone".tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _whatsapp,
                        decoration: InputDecoration(labelText: "WhatsApp".tr),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: "Bookings email".tr),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lead,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Lead time (days)".tr,
                    helperText:
                        "Days before travel that payment must be complete. Empty = app default."
                            .tr,
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ||
                          int.tryParse(v!.trim()) != null
                      ? null
                      : "Whole days".tr,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _policy,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: "Refund policy".tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text("Default policy".tr),
                    ),
                    for (final p in _policies)
                      DropdownMenuItem(value: p.uuid, child: Text(p.name)),
                    if (_policy != null &&
                        !_policies.any((p) => p.uuid == _policy))
                      DropdownMenuItem(
                        value: _policy,
                        child: Text(widget.operator?.refund_policy_name ?? ''),
                      ),
                  ],
                  onChanged: (v) => setState(() => _policy = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text("Cancel".tr)),
        Obx(
          () => FilledButton(
            onPressed: widget.controller.isSaving.value ? null : _save,
            child: Text("Save".tr),
          ),
        ),
      ],
    );
  }
}
