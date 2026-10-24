import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/st/st.dart';

import 'settings_controller.dart';

/// Business rules the API reads at run time (`AppSetting`). The mobile app's
/// own copies (AppConfig) are only display defaults.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = Get.put(SettingsController(sl()));
  final _formKey = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  final _packing = TextEditingController();
  late final bool _canEdit = can('settings.manage');

  static const _numbers = [
    (
      'default_lead_time_days',
      'Default lead time (days)',
      'Payment must be complete this many days before travel, unless the trip or operator says otherwise.',
    ),
    (
      'missed_before_pause',
      'Missed installments before pausing',
      'Consecutive misses that pause a goal.',
    ),
    (
      'reminder_days_before_due',
      'Reminder days before due',
      'When the "installment due" push goes out.',
    ),
    (
      'min_payment_tzs',
      'Minimum payment (TSh)',
      'Smallest mobile money payment, in whole shillings.',
    ),
    (
      'min_payment_other_major',
      'Minimum payment (USD/EUR/GBP)',
      'Smallest card payment, in whole units.',
    ),
    (
      'pending_payment_timeout_minutes',
      'Pending payment timeout (minutes)',
      'Unconfirmed payments are failed after this.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (final f in _numbers) {
      _fields[f.$1] = TextEditingController();
    }
    ever(_controller.settings, _fill);
    if (_controller.settings.value != null) _fill(_controller.settings.value);
  }

  @override
  void dispose() {
    Get.delete<SettingsController>();
    super.dispose();
  }

  void _fill(AppSettings? s) {
    if (s == null) return;
    final json = s.toJson();
    for (final f in _numbers) {
      _fields[f.$1]!.text = '${json[f.$1]}';
    }
    _packing.text = s.packing_list;
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    _controller.save({
      for (final f in _numbers) f.$1: int.parse(_fields[f.$1]!.text.trim()),
      'packing_list': _packing.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = _controller.settings.value;
      if (s == null) return const Center(child: CircularProgressIndicator());
      return Form(
        key: _formKey,
        child: PageBody(
          maxWidth: 900,
          title: "Business rules".tr,
          subtitle: s.updated_at == null
              ? null
              : "Last changed @date".trParams({
                  'date': TimeUtil.formatDateTime(s.updated_at),
                }),
          actions: [
            PermissionGate(
              code: 'settings.manage',
              child: FilledButton.icon(
                onPressed: _controller.isSaving.value ? null : _save,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text("Save".tr),
              ),
            ),
          ],
          children: [
            SectionCard(
              title: "Payments & schedule".tr,
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final f in _numbers)
                    SizedBox(
                      width: 400,
                      child: TextFormField(
                        controller: _fields[f.$1],
                        enabled: _canEdit,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: f.$2.tr,
                          helperText: f.$3.tr,
                          helperMaxLines: 2,
                        ),
                        validator: (v) => int.tryParse((v ?? '').trim()) == null
                            ? "Whole number".tr
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            SectionCard(
              title: "Default packing list".tr,
              child: TextFormField(
                controller: _packing,
                enabled: _canEdit,
                minLines: 6,
                maxLines: 16,
                decoration: InputDecoration(
                  helperText:
                      "One item per line. Added to every new booking.".tr,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
