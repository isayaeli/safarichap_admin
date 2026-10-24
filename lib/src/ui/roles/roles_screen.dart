import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/st/st.dart';

import 'roles_controller.dart';

/// Roles on the left; the selected role's permissions, grouped by area, on
/// the right. Built-in roles can be edited but not renamed or deleted;
/// Super Admin always has everything.
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final _controller = Get.put(RolesController(sl(), Get.find()));

  @override
  void dispose() {
    Get.delete<RolesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final list = _RoleList(controller: _controller);
          final editor = Obx(() {
            final role = _controller.selectedRole;
            if (role == null && !_controller.creating.value) {
              return Card(child: Center(child: Text("Pick a role".tr)));
            }
            return _RoleEditor(
              key: ValueKey(role?.uuid ?? 'new'),
              controller: _controller,
              role: role,
            );
          });
          if (constraints.maxWidth < 800) {
            return Column(
              children: [
                SizedBox(height: 220, child: list),
                const SizedBox(height: 16),
                Expanded(child: editor),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 300, child: list),
              const SizedBox(width: 16),
              Expanded(child: editor),
            ],
          );
        },
      ),
    );
  }
}

class _RoleList extends StatelessWidget {
  final RolesController controller;
  const _RoleList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Roles".tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: PermissionGate(
              code: 'roles.manage',
              child: IconButton(
                tooltip: "New role".tr,
                icon: const Icon(Icons.add),
                onPressed: controller.startNew,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(
              () => ListView(
                children: [
                  for (final r in controller.roles)
                    ListTile(
                      selected: controller.selected.value == r.uuid,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      title: Text(r.name),
                      subtitle: Text(
                        "@n permissions · @s staff".trParams({
                          'n': '${r.permissions.length}',
                          's': '${r.staff_count}',
                        }),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: r.is_system
                          ? const Icon(Icons.lock_outline, size: 16)
                          : null,
                      onTap: () => controller.select(r.uuid),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleEditor extends StatefulWidget {
  final RolesController controller;
  final Role? role;
  const _RoleEditor({super.key, required this.controller, this.role});

  @override
  State<_RoleEditor> createState() => _RoleEditorState();
}

class _RoleEditorState extends State<_RoleEditor> {
  late final _name = TextEditingController(text: widget.role?.name);
  late final _description = TextEditingController(
    text: widget.role?.description,
  );
  late Set<String> _codes = {...?widget.role?.permissions};
  late final bool _locked = widget.role?.isLocked ?? false;
  late final bool _editable = can('roles.manage') && !_locked;

  void _toggleGroup(List<AdminPermission> perms, bool on) {
    setState(() {
      final codes = perms.map((p) => p.code);
      _codes = on ? {..._codes, ...codes} : (_codes..removeAll(codes));
    });
  }

  Future<void> _delete() async {
    final role = widget.role!;
    final ok = await confirmAction(
      title: "Delete @name?".trParams({'name': role.name}),
      message: role.staff_count > 0
          ? "@n staff members lose the permissions this role gave them."
                .trParams({'n': '${role.staff_count}'})
          : "Nobody has this role.".tr,
      destructive: true,
      confirmLabel: "Delete".tr,
    );
    if (ok != null) widget.controller.delete(role);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groups = widget.controller.groupedPermissions;
    final role = widget.role;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _name,
                        enabled: _editable && !(role?.is_system ?? false),
                        decoration: InputDecoration(labelText: "Role name".tr),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _description,
                        enabled: _editable,
                        decoration: InputDecoration(
                          labelText: "Description".tr,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (role != null && !role.is_system && can('roles.manage'))
                  IconButton(
                    tooltip: "Delete role".tr,
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                if (_editable)
                  Obx(
                    () => FilledButton(
                      onPressed:
                          widget.controller.isSaving.value ||
                              _name.text.trim().isEmpty && role == null
                          ? null
                          : () => widget.controller.save(
                              uuid: role?.uuid,
                              name: _name.text.trim(),
                              description: _description.text.trim(),
                              codes: _codes,
                            ),
                      child: Text("Save".tr),
                    ),
                  ),
              ],
            ),
          ),
          if (_locked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatusChip(
                label: "Super Admin always has every permission".tr,
                color: Colors.blue,
              ),
            ),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                for (final e in groups.entries) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key.tr,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_editable)
                        TextButton(
                          onPressed: () => _toggleGroup(
                            e.value,
                            !e.value.every((p) => _codes.contains(p.code)),
                          ),
                          child: Text(
                            e.value.every((p) => _codes.contains(p.code))
                                ? "Clear".tr
                                : "Select all".tr,
                          ),
                        ),
                    ],
                  ),
                  for (final p in e.value)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _locked || _codes.contains(p.code),
                      onChanged: _editable
                          ? (on) => setState(
                              () => on == true
                                  ? _codes.add(p.code)
                                  : _codes.remove(p.code),
                            )
                          : null,
                      title: Text(p.label.tr),
                      subtitle: Text(
                        p.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
