import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/booking/booking.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/goals/goal_details_screen.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
import 'package:safarichap_admin/src/ui/users/user_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bookings_controller.dart';
import 'widgets/document_dialog.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String uuid;
  const BookingDetailsScreen({super.key, required this.uuid});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  // Unique per page: the same record can be open twice (customer → goal → customer).
  late final _tag = '${widget.uuid}#${identityHashCode(this)}';
  late final _controller = Get.put(
    BookingDetailController(sl(), widget.uuid),
    tag: _tag,
  );
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<BookingDetailController>(tag: _tag);
    super.dispose();
  }

  Future<void> _setStatus(AdminBooking b, BookingStatus status) async {
    final ok = await confirmAction(
      title: "Mark booking @status?".trParams({
        'status': status.label.toLowerCase(),
      }),
      message: status == BookingStatus.cancelled
          ? "This only changes the booking. Refunds are handled from the goal."
                .tr
          : "The traveller sees the new status in the app.".tr,
      destructive: status == BookingStatus.cancelled,
    );
    if (ok != null) _controller.updateStatus(status);
  }

  Future<void> _deleteDocument(TripDocument doc) async {
    final ok = await confirmAction(
      title: "Remove document?".tr,
      message: "@title is removed from the traveller's trip.".trParams({
        'title': doc.title,
      }),
      confirmLabel: "Remove".tr,
      destructive: true,
    );
    if (ok != null) _controller.deleteDocument(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Booking".tr)),
      body: Obx(() {
        final b = _controller.booking.value;
        if (b == null) return const Center(child: CircularProgressIndicator());
        final link = TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        );
        return PageBody(
          title: b.confirmation_code,
          subtitle: b.itinerary_title,
          actions: [
            StatusChip.booking(b.status),
            PermissionGate(
              code: 'bookings.manage',
              child: PopupMenuButton<BookingStatus>(
                enabled: !_controller.isSaving.value,
                onSelected: (s) => _setStatus(b, s),
                itemBuilder: (_) => [
                  for (final s in BookingStatus.values.where(
                    (s) => s != b.status,
                  ))
                    PopupMenuItem(
                      value: s,
                      child: Text(
                        "Mark @status".trParams({
                          'status': s.label.toLowerCase(),
                        }),
                      ),
                    ),
                ],
                child: Chip(
                  avatar: const Icon(Icons.edit_outlined, size: 16),
                  label: Text("Change status".tr),
                ),
              ),
            ),
            PermissionGate(
              code: 'bookings.manage',
              child: OutlinedButton.icon(
                onPressed: _controller.isSaving.value
                    ? null
                    : _controller.notifyTraveller,
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: Text("Notify traveller".tr),
              ),
            ),
          ],
          children: [
            SectionCard(
              title: "Trip".tr,
              child: InfoGrid(
                children: [
                  InfoRow(
                    label: "Customer".tr,
                    child: InkWell(
                      onTap: () =>
                          _shell.open(UserDetailsScreen(uuid: b.user.uuid)),
                      child: Text(b.user.displayName, style: link),
                    ),
                  ),
                  InfoRow(label: "Phone".tr, value: b.user.phone_number),
                  InfoRow(
                    label: "Goal".tr,
                    child: InkWell(
                      onTap: () =>
                          _shell.open(GoalDetailsScreen(uuid: b.goal_uuid)),
                      child: Text("Open goal".tr, style: link),
                    ),
                  ),
                  InfoRow(label: "Operator".tr, value: b.operator_name),
                  InfoRow(
                    label: "Travel date".tr,
                    value: TimeUtil.formatDate(b.travel_date),
                  ),
                  InfoRow(label: "Travellers".tr, value: '${b.travellers}'),
                  InfoRow(
                    label: "Booked".tr,
                    value: TimeUtil.formatDateTime(b.created_at),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: "Documents".tr,
              actions: [
                PermissionGate(
                  code: 'bookings.manage',
                  child: TextButton.icon(
                    onPressed: () =>
                        Get.dialog(DocumentDialog(controller: _controller)),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text("Add".tr),
                  ),
                ),
              ],
              child: b.documents.isEmpty
                  ? Text("No documents".tr)
                  : Column(
                      children: [
                        for (final d in b.documents)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              d.url != null
                                  ? Icons.description_outlined
                                  : Icons.notes_outlined,
                            ),
                            title: Text(d.title),
                            subtitle: Text(
                              d.content?.split('\n').take(2).join(' · ') ??
                                  d.type.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Wrap(
                              children: [
                                if (d.url != null)
                                  IconButton(
                                    tooltip: "Open".tr,
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        launchUrl(Uri.parse(d.url!)),
                                  ),
                                PermissionGate(
                                  code: 'bookings.manage',
                                  child: Wrap(
                                    children: [
                                      IconButton(
                                        tooltip: "Edit".tr,
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => Get.dialog(
                                          DocumentDialog(
                                            controller: _controller,
                                            document: d,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: "Remove".tr,
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                        ),
                                        onPressed: () => _deleteDocument(d),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }
}
