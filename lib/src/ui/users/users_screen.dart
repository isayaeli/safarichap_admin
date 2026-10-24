import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'user_details_screen.dart';
import 'users_controller.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _controller = Get.put(UsersController(sl()));
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<UsersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<AdminUser>(
        controller: _controller,
        searchHint: 'Name, phone or email',
        emptyMessage: 'No customers match',
        onTap: (u) async {
          await _shell.open(UserDetailsScreen(uuid: u.uuid));
          _controller.load();
        },
        filters: [
          FilterDropdown<String>(
            label: 'Residency',
            value: _controller.filters['residency'],
            options: {for (final r in Residency.values) r.wire: r.label},
            onChanged: (v) => _controller.setFilter('residency', v),
          ),
          FilterDropdown<String>(
            label: 'KYC',
            value: _controller.filters['kyc_status'],
            options: {for (final k in KycStatus.values) k.wire: k.label},
            onChanged: (v) => _controller.setFilter('kyc_status', v),
          ),
          FilterDropdown<String>(
            label: 'Account',
            value: _controller.filters['is_active'],
            options: {'true': 'Active'.tr, 'false': 'Disabled'.tr},
            onChanged: (v) => _controller.setFilter('is_active', v),
          ),
        ],
        actions: [
          PermissionGate(
            code: 'users.export',
            child: OutlinedButton.icon(
              onPressed: _controller.isExporting.value
                  ? null
                  : _controller.exportCsv,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: Text("Export CSV".tr),
            ),
          ),
        ],
        columns: [
          TableColumn(
            'Customer',
            (u) => TwoLineCell(u.displayName, u.email ?? u.phone_number),
            size: ColumnSize.L,
            sortKey: 'full_name',
          ),
          TableColumn('Phone', (u) => Text(u.phone_number ?? '-')),
          TableColumn(
            'Residency',
            (u) => Text(u.residency?.label ?? '-'),
            size: ColumnSize.S,
          ),
          TableColumn(
            'KYC',
            (u) => StatusChip.kyc(u.kyc_status),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Goals',
            (u) => Text('${u.active_goals_count} / ${u.goals_count}'),
            size: ColumnSize.S,
            numeric: true,
            sortKey: 'goals_count',
          ),
          TableColumn(
            'Account',
            (u) => StatusChip.active(u.is_active, off: 'Disabled'.tr),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Joined',
            (u) => Text(TimeUtil.formatDate(u.created_at)),
            sortKey: 'created_at',
          ),
          TableColumn(
            'Last seen',
            (u) => Text(TimeUtil.formatDate(u.last_login)),
            sortKey: 'last_login',
          ),
        ],
      ),
    );
  }
}
