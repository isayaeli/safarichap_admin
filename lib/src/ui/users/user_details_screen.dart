import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/components/simple_table.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:safarichap_admin/src/core/components/busy_button.dart';
import 'package:safarichap_admin/src/routes/app_routes.dart';

import 'users_controller.dart';
import 'widgets/edit_user_dialog.dart';

class UserDetailsScreen extends StatefulWidget {
  final String uuid;
  const UserDetailsScreen({super.key, required this.uuid});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // Unique per page: the same record can be open twice (customer → goal → customer).
  late final _tag = '${widget.uuid}#${identityHashCode(this)}';
  late final _controller = Get.put(
    UserDetailController(sl(), widget.uuid),
    tag: _tag,
  );
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<UserDetailController>(tag: _tag);
    super.dispose();
  }

  Future<void> _toggleActive(AdminUser user) async {
    final disable = user.is_active;
    final ok = await confirmAction(
      title: disable ? "Disable account?".tr : "Enable account?".tr,
      message: disable
          ? "@name won't be able to sign in to the app until the account is enabled again. Goals and payments are kept."
                .trParams({'name': user.displayName})
          : "@name will be able to sign in again.".trParams({
              'name': user.displayName,
            }),
      confirmLabel: disable ? "Disable".tr : "Enable".tr,
      destructive: disable,
    );
    if (ok == null) return;
    await _controller.updateUser({
      'is_active': !disable,
    }, successMessage: disable ? "Account disabled".tr : "Account enabled".tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer".tr)),
      body: Obx(() {
        final user = _controller.user.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return PageBody(
          title: user.displayName,
          subtitle: "Joined @date".trParams({
            'date': TimeUtil.formatDate(user.created_at),
          }),
          actions: [
            PermissionGate(
              code: 'users.manage',
              child: OutlinedButton.icon(
                onPressed: () => Get.dialog(
                  EditUserDialog(user: user, controller: _controller),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text("Edit".tr),
              ),
            ),
            PermissionGate(
              code: 'users.manage',
              child: BusyButton(
                kind: BusyButtonKind.tonal,
                busy: _controller.isSaving.value,
                onPressed: () => _toggleActive(user),
                icon: user.is_active ? Icons.block : Icons.check_circle_outline,
                label: user.is_active ? "Disable".tr : "Enable".tr,
              ),
            ),
          ],
          children: [
            SectionCard(
              title: "Profile".tr,
              child: InfoGrid(
                children: [
                  InfoRow(label: "Phone".tr, value: user.phone_number),
                  InfoRow(label: "Email".tr, value: user.email),
                  InfoRow(label: "Residency".tr, value: user.residency?.label),
                  InfoRow(label: "Currency".tr, value: user.preferred_currency),
                  InfoRow(label: "Country".tr, value: user.country),
                  InfoRow(
                    label: "KYC".tr,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusChip.kyc(user.kyc_status),
                    ),
                  ),
                  InfoRow(
                    label: "Account".tr,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusChip.active(
                        user.is_active,
                        off: 'Disabled'.tr,
                      ),
                    ),
                  ),
                  InfoRow(
                    label: "Reminders".tr,
                    value: user.notifications_enabled ? "On".tr : "Off".tr,
                  ),
                  InfoRow(
                    label: "Last seen".tr,
                    value: user.last_login == null
                        ? null
                        : timeago.format(user.last_login!),
                  ),
                  if (user.is_staff)
                    InfoRow(label: "Staff".tr, value: "Yes".tr),
                ],
              ),
            ),
            SectionCard(
              title: "Goals (@n)".trParams({'n': '${user.goals.length}'}),
              child: SimpleTable(
                items: user.goals,
                headers: const [
                  'Trip',
                  'Status',
                  'Paid',
                  'Total',
                  'Travel date',
                ],
                onTap: (g) => _shell.open(AppRoutes.goal(g.uuid)),
                emptyMessage: 'No goals yet',
                cells: (g) => [
                  Text(g.title),
                  StatusChip.goal(g.status),
                  Text(g.paid.formatted),
                  Text(g.total.formatted),
                  Text(TimeUtil.formatDate(g.travel_date)),
                ],
              ),
            ),
            SectionCard(
              title: "Recent payments".tr,
              child: SimpleTable(
                items: user.payments,
                headers: const [
                  'Date',
                  'Amount',
                  'Method',
                  'Status',
                  'Receipt',
                ],
                onTap: (p) => _shell.open(AppRoutes.payment(p.uuid)),
                emptyMessage: 'No payments yet',
                cells: (p) => [
                  Text(TimeUtil.formatDateTime(p.created_at)),
                  Text(p.money.formatted),
                  Text(p.method.label),
                  StatusChip.payment(p.status),
                  Text(p.receipt_number ?? '-'),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final devices = SectionCard(
                  title: "Devices".tr,
                  child: SimpleTable(
                    items: user.devices,
                    headers: const ['Platform', 'Push', 'Last update'],
                    emptyMessage: 'No devices registered',
                    cells: (d) => [
                      Text(d.platform),
                      Text(d.notifications_enabled ? "On".tr : "Off".tr),
                      Text(TimeUtil.formatDateTime(d.updated_at)),
                    ],
                  ),
                );
                final kyc = SectionCard(
                  title: "ID documents".tr,
                  child: SimpleTable(
                    items: user.kyc_documents,
                    headers: const ['Type', 'Number', 'Status', 'Submitted'],
                    emptyMessage: 'No documents submitted',
                    cells: (k) => [
                      Text(k.document_type.label),
                      SelectableText(k.document_number),
                      StatusChip.kyc(k.status),
                      Text(TimeUtil.formatDate(k.created_at)),
                    ],
                  ),
                );
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [devices, const SizedBox(height: 16), kyc],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: devices),
                    const SizedBox(width: 16),
                    Expanded(child: kyc),
                  ],
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
