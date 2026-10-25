import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';
import 'package:safarichap_admin/src/core/components/busy_button.dart';

import '../users_controller.dart';

class EditUserDialog extends StatefulWidget {
  final AdminUser user;
  final UserDetailController controller;
  const EditUserDialog({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late final _name = TextEditingController(text: widget.user.full_name);
  late final _phone = TextEditingController(text: widget.user.phone_number);
  late final _email = TextEditingController(text: widget.user.email);
  late final _country = TextEditingController(text: widget.user.country);
  late Residency? _residency = widget.user.residency;
  late String? _currency = widget.user.preferred_currency;
  late bool _notifications = widget.user.notifications_enabled;

  String? _orNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final ok = await widget.controller.updateUser({
      'full_name': _orNull(_name),
      'phone_number': _orNull(_phone),
      'email': _orNull(_email),
      'country': _country.text.trim().toUpperCase(),
      'residency': _residency?.wire,
      'preferred_currency': _currency,
      'notifications_enabled': _notifications,
    });
    if (ok) closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit customer".tr),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: "Full name".tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: "Phone".tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                decoration: InputDecoration(labelText: "Email".tr),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Residency>(
                      isExpanded:
                          true, // long labels ellipsize instead of overflowing
                      initialValue: _residency,
                      decoration: InputDecoration(labelText: "Residency".tr),
                      items: [
                        for (final r in Residency.values)
                          DropdownMenuItem(value: r, child: Text(r.label)),
                      ],
                      onChanged: (v) => setState(() => _residency = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded:
                          true, // long labels ellipsize instead of overflowing
                      initialValue: _currency,
                      decoration: InputDecoration(labelText: "Currency".tr),
                      items: [
                        for (final c in Currency.values)
                          DropdownMenuItem(value: c.code, child: Text(c.code)),
                      ],
                      onChanged: (v) => setState(() => _currency = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _country,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: "Country".tr,
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Payment reminders".tr),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => closeDialog(), child: Text("Cancel".tr)),
        Obx(
          () => BusyButton(
            busy: widget.controller.isSaving.value,
            onPressed: _save,
            label: "Save".tr,
          ),
        ),
      ],
    );
  }
}
