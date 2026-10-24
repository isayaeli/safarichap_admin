import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/st/st.dart';

import 'broadcast_dialog.dart';
import 'notifications_controller.dart';

/// Broadcasts staff sent, and every notification customers received
/// (automatic ones included).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _broadcasts = Get.put(BroadcastsController(sl()));
  final _sent = Get.put(SentNotificationsController(sl()));

  static const _types = [
    'announcement',
    'payment_success',
    'payment_failed',
    'installment_due',
    'installment_missed',
    'goal_completed',
    'goal_paused',
    'goal_expired',
    'goal_cancelled',
    'kyc_verified',
    'kyc_rejected',
    'booking_updated',
  ];

  @override
  void dispose() {
    Get.delete<BroadcastsController>();
    Get.delete<SentNotificationsController>();
    super.dispose();
  }

  String _audience(Map<String, dynamic> a) => switch (a['kind']) {
    'residency' => "Residency: @v".trParams({'v': '${a['residency']}'}),
    'goal_status' => "Goal status: @v".trParams({'v': '${a['goal_status']}'}),
    'users' => "@n chosen customers".trParams({
      'n': '${(a['user_uuids'] as List?)?.length ?? 0}',
    }),
    _ => "All customers".tr,
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: "Broadcasts".tr),
                      Tab(text: "All notifications".tr),
                    ],
                  ),
                ),
                PermissionGate(
                  code: 'notifications.send',
                  child: FilledButton.icon(
                    onPressed: () =>
                        Get.dialog(BroadcastDialog(controller: _broadcasts)),
                    icon: const Icon(Icons.campaign_outlined, size: 18),
                    label: Text("New broadcast".tr),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                PagedTable<Broadcast>(
                  controller: _broadcasts,
                  searchHint: 'Title or message',
                  emptyMessage: 'No broadcasts sent yet',
                  columns: [
                    TableColumn(
                      'Sent',
                      (b) => Text(TimeUtil.formatDateTime(b.created_at)),
                      sortKey: 'created_at',
                    ),
                    TableColumn(
                      'Title',
                      (b) => TwoLineCell(b.title, b.message),
                      size: ColumnSize.L,
                    ),
                    TableColumn('Audience', (b) => Text(_audience(b.audience))),
                    TableColumn(
                      'Recipients',
                      (b) => Text('${b.recipients}'),
                      numeric: true,
                      size: ColumnSize.S,
                    ),
                    TableColumn('By', (b) => Text(b.sent_by ?? '-')),
                  ],
                ),
                Obx(
                  () => PagedTable<AdminNotification>(
                    controller: _sent,
                    searchHint: 'Title, message or customer',
                    emptyMessage: 'No notifications',
                    filters: [
                      FilterDropdown<String>(
                        label: 'Type',
                        value: _sent.filters['type'],
                        width: 210,
                        options: {
                          for (final t in _types)
                            t: t.replaceAll('_', ' ').capitalizeFirst!,
                        },
                        onChanged: (v) => _sent.setFilter('type', v),
                      ),
                    ],
                    columns: [
                      TableColumn(
                        'Date',
                        (n) => Text(TimeUtil.formatDateTime(n.created_at)),
                        sortKey: 'created_at',
                      ),
                      TableColumn(
                        'Customer',
                        (n) => TwoLineCell(
                          n.user.displayName,
                          n.user.phone_number,
                        ),
                      ),
                      TableColumn(
                        'Notification',
                        (n) => TwoLineCell(n.title, n.message),
                        size: ColumnSize.L,
                      ),
                      TableColumn(
                        'Type',
                        (n) => Text(n.type.replaceAll('_', ' ')),
                      ),
                      TableColumn(
                        'Read',
                        (n) => Icon(
                          n.is_read ? Icons.done_all : Icons.done,
                          size: 18,
                        ),
                        size: ColumnSize.S,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
