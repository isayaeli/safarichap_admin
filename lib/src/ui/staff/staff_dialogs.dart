import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';

import 'staff_controller.dart';

/// Role checkboxes with each role's description.
class RolePicker extends StatelessWidget {
  final List<Role> roles;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  const RolePicker({
    super.key,
    required this.roles,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final r in roles)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: selected.contains(r.uuid),
            title: Text(r.name),
            subtitle: r.description.isEmpty ? null : Text(r.description),
            onChanged: (on) => onChanged(
              on == true
                  ? {...selected, r.uuid}
                  : ({...selected}..remove(r.uuid)),
            ),
          ),
      ],
    );
  }
}

class InviteStaffDialog extends StatefulWidget {
  final StaffController controller;
  const InviteStaffDialog({super.key, required this.controller});

  @override
  State<InviteStaffDialog> createState() => _InviteStaffDialogState();
}

class _InviteStaffDialogState extends State<InviteStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _name = TextEditingController();
  Set<String> _roles = {};
  String? _link;

  Future<void> _invite() async {
    if (_formKey.currentState?.validate() != true || _roles.isEmpty) return;
    final link = await widget.controller.invite(
      email: _email.text.trim(),
      fullName: _name.text.trim(),
      roleUuids: _roles.toList(),
    );
    if (link != null) setState(() => _link = link);
  }

  @override
  Widget build(BuildContext context) {
    if (_link != null) {
      return AlertDialog(
        title: Text("Invitation sent".tr),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@email got an email with a link to set their password. You can also share this link directly:"
                    .trParams({'email': _email.text.trim()}),
              ),
              const SizedBox(height: 12),
              if (_link!.isEmpty)
                Text(
                  "The server couldn't create a link; they can use “Forgot password?” on the sign-in page."
                      .tr,
                )
              else
                SelectableText(
                  _link!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
            ],
          ),
        ),
        actions: [
          if (_link!.isNotEmpty)
            TextButton(
              onPressed: () => widget.controller.copy(_link!),
              child: Text("Copy link".tr),
            ),
          FilledButton(onPressed: Get.back, child: Text("Done".tr)),
        ],
      );
    }
    return AlertDialog(
      title: Text("Invite staff".tr),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: "Full name".tr),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? "Required".tr : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Work email".tr),
                  validator: (v) =>
                      (v ?? '').contains('@') ? null : "Enter an email".tr,
                ),
                const SizedBox(height: 16),
                Text(
                  "Roles".tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Obx(
                  () => RolePicker(
                    roles: widget.controller.roles.toList(),
                    selected: _roles,
                    onChanged: (v) => setState(() => _roles = v),
                  ),
                ),
                if (_roles.isEmpty)
                  Text(
                    "Pick at least one role".tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
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
            onPressed: widget.controller.isSaving.value ? null : _invite,
            child: Text("Send invite".tr),
          ),
        ),
      ],
    );
  }
}

class EditStaffDialog extends StatefulWidget {
  final StaffController controller;
  final StaffMember member;
  const EditStaffDialog({
    super.key,
    required this.controller,
    required this.member,
  });

  @override
  State<EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<EditStaffDialog> {
  late final _name = TextEditingController(text: widget.member.user.full_name);
  late Set<String> _roles = {for (final r in widget.member.roles) r.uuid};

  Future<void> _save() async {
    final ok = await widget.controller.updateStaff(widget.member, {
      'full_name': _name.text.trim(),
      'roles': _roles.toList(),
    });
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.member.user.displayName),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.member.user.email ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: "Full name".tr),
              ),
              const SizedBox(height: 16),
              Text(
                "Roles".tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Obx(
                () => RolePicker(
                  roles: widget.controller.roles.toList(),
                  selected: _roles,
                  onChanged: (v) => setState(() => _roles = v),
                ),
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
