import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'staff_controller.dart';
import 'staff_dialogs.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _controller = Get.put(StaffController(sl()));
  final SessionController _session = Get.find();

  @override
  void dispose() {
    Get.delete<StaffController>();
    super.dispose();
  }

  bool _isMe(StaffMember m) => m.user.uuid == _session.me.value?.user.uuid;

  Future<void> _toggleActive(StaffMember m) async {
    final deactivate = m.is_active;
    final ok = await confirmAction(
      title: deactivate
          ? "Deactivate @name?".trParams({'name': m.user.displayName})
          : "Reactivate @name?".trParams({'name': m.user.displayName}),
      message: deactivate
          ? "They're signed out of the dashboard on their next request. Their roles are kept."
                .tr
          : "They can sign in to the dashboard again with their current roles."
                .tr,
      destructive: deactivate,
      confirmLabel: deactivate ? "Deactivate".tr : "Reactivate".tr,
    );
    if (ok != null) {
      _controller.updateStaff(m, {
        'is_active': !deactivate,
      }, message: deactivate ? "Deactivated".tr : "Reactivated".tr);
    }
  }

  Future<void> _remove(StaffMember m) async {
    final ok = await confirmAction(
      title: "Remove @name from staff?".trParams({'name': m.user.displayName}),
      message:
          "Removes dashboard access. Their sign-in and any customer account stay. Their actions remain in the audit log."
              .tr,
      destructive: true,
      confirmLabel: "Remove".tr,
    );
    if (ok != null) _controller.remove(m);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<StaffMember>(
        controller: _controller,
        searchHint: 'Name, email or phone',
        emptyMessage: 'No staff yet',
        onTap: can('staff.manage')
            ? (m) => Get.dialog(
                EditStaffDialog(controller: _controller, member: m),
              )
            : null,
        filters: [
          FilterDropdown<String>(
            label: 'Role',
            value: _controller.filters['roles__uuid'],
            options: {for (final r in _controller.roles) r.uuid: r.name},
            onChanged: (v) => _controller.setFilter('roles__uuid', v),
          ),
          FilterDropdown<String>(
            label: 'Access',
            value: _controller.filters['is_active'],
            options: {'true': 'Active'.tr, 'false': 'Deactivated'.tr},
            onChanged: (v) => _controller.setFilter('is_active', v),
          ),
        ],
        actions: [
          PermissionGate(
            code: 'staff.manage',
            child: FilledButton.icon(
              onPressed: () =>
                  Get.dialog(InviteStaffDialog(controller: _controller)),
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: Text("Invite staff".tr),
            ),
          ),
        ],
        columns: [
          TableColumn(
            'Name',
            (m) => TwoLineCell(
              _isMe(m)
                  ? "@name (you)".trParams({'name': m.user.displayName})
                  : m.user.displayName,
              m.user.email,
            ),
            size: ColumnSize.L,
            sortKey: 'user__full_name',
          ),
          TableColumn(
            'Roles',
            (m) => Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                for (final r in m.roles)
                  StatusChip(
                    label: r.name,
                    color: safariChapColors.tertiaryPressedColor!,
                  ),
              ],
            ),
            size: ColumnSize.L,
          ),
          TableColumn(
            'Access',
            (m) => StatusChip.active(m.is_active, off: 'Deactivated'.tr),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Last seen',
            (m) => Text(
              m.last_seen_at == null
                  ? "Never".tr
                  : timeago.format(m.last_seen_at!),
            ),
            sortKey: 'last_seen_at',
          ),
          TableColumn('Invited by', (m) => Text(m.invited_by ?? '-')),
          TableColumn(
            '',
            (m) => _isMe(m)
                ? const SizedBox.shrink()
                : PermissionGate(
                    code: 'staff.manage',
                    child: PopupMenuButton<String>(
                      onSelected: (v) =>
                          v == 'toggle' ? _toggleActive(m) : _remove(m),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            m.is_active ? "Deactivate".tr : "Reactivate".tr,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text("Remove from staff".tr),
                        ),
                      ],
                    ),
                  ),
            fixedWidth: 60,
          ),
        ],
      ),
    );
  }
}
