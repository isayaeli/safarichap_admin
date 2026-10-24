import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';

import '../catalogue_controller.dart';

class RefundPolicyDialog extends StatefulWidget {
  final CatalogueController<RefundPolicy> controller;
  final RefundPolicy? policy;
  const RefundPolicyDialog({super.key, required this.controller, this.policy});

  @override
  State<RefundPolicyDialog> createState() => _RefundPolicyDialogState();
}

class _TierFields {
  final days = TextEditingController();
  final pct = TextEditingController();
  _TierFields(int d, int p) {
    days.text = '$d';
    pct.text = '$p';
  }
}

class _RefundPolicyDialogState extends State<RefundPolicyDialog> {
  late final _name = TextEditingController(text: widget.policy?.name);
  late final _description = TextEditingController(
    text: widget.policy?.description,
  );

  /// Shown as a percentage; stored as basis points (250 = 2.5%).
  late final _fee = TextEditingController(
    text: ((widget.policy?.processing_fee_bps ?? 250) / 100).toString(),
  );
  late bool _isDefault = widget.policy?.is_default ?? false;
  late final List<_TierFields> _tiers = [
    for (final t
        in widget.policy?.tiers ??
            [
              RefundTier(min_days: 61, percentage: 90),
              RefundTier(min_days: 31, percentage: 50),
              RefundTier(min_days: 0, percentage: 0),
            ])
      _TierFields(t.min_days, t.percentage),
  ];

  Future<void> _save() async {
    final fee = double.tryParse(_fee.text.trim());
    if (_name.text.trim().isEmpty || fee == null) return;
    final ok = await widget.controller.save(
      uuid: widget.policy?.uuid,
      body: {
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'processing_fee_bps': (fee * 100).round(),
        'is_default': _isDefault,
        'tiers': [
          for (final t in _tiers)
            {
              'min_days': int.tryParse(t.days.text.trim()) ?? -1,
              'percentage': int.tryParse(t.pct.text.trim()) ?? -1,
            },
        ],
      },
    );
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return AlertDialog(
      title: Text(
        widget.policy == null
            ? "New refund policy".tr
            : "Edit refund policy".tr,
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: "Name".tr),
              ),
              const SizedBox(height: 16),
              Text(
                "Refund by days left before travel".tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "The first tier the trip qualifies for applies. Keep a 0-day tier."
                    .tr,
                style: muted,
              ),
              const SizedBox(height: 8),
              for (final (i, t) in _tiers.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: t.days,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "At least (days)".tr,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: t.pct,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Refund %".tr),
                        ),
                      ),
                      IconButton(
                        tooltip: "Remove".tr,
                        onPressed: _tiers.length > 1
                            ? () => setState(() => _tiers.removeAt(i))
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: () => setState(() => _tiers.add(_TierFields(0, 0))),
                icon: const Icon(Icons.add, size: 18),
                label: Text("Add tier".tr),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fee,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Processing fee (% of amount paid)".tr,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Description".tr,
                  helperText:
                      "Shown to customers word for word when they cancel.".tr,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Default policy".tr),
                subtitle: Text(
                  "Used for operators without their own policy".tr,
                ),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
            ],
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
