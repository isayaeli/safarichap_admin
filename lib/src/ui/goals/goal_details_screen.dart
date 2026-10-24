import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/components/simple_table.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/money.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/bookings/booking_details_screen.dart';
import 'package:safarichap_admin/src/ui/payments/payment_details_screen.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
import 'package:safarichap_admin/src/ui/users/user_details_screen.dart';

import 'goals_controller.dart';
import 'widgets/goal_progress.dart';
import 'widgets/reschedule_dialog.dart';

class GoalDetailsScreen extends StatefulWidget {
  final String uuid;
  const GoalDetailsScreen({super.key, required this.uuid});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  // Unique per page: the same record can be open twice (customer → goal → customer).
  late final _tag = '${widget.uuid}#${identityHashCode(this)}';
  late final _controller = Get.put(
    GoalDetailController(sl(), widget.uuid),
    tag: _tag,
  );
  final ShellController _shell = Get.find();

  static const _reschedulable = {
    GoalStatus.active,
    GoalStatus.paused,
    GoalStatus.expired,
  };
  static const _cancellable = {
    GoalStatus.draft,
    GoalStatus.active,
    GoalStatus.paused,
    GoalStatus.expired,
  };

  @override
  void dispose() {
    Get.delete<GoalDetailController>(tag: _tag);
    super.dispose();
  }

  Future<void> _pause(GoalDetail goal) async {
    final reason = await confirmAction(
      title: "Pause goal?".tr,
      message:
          "Payments are still accepted, but the goal stops counting missed installments. The customer is notified."
              .tr,
      confirmLabel: "Pause".tr,
      reasonLabel: "Internal reason (audit log)".tr,
    );
    if (reason != null) {
      _controller.act('pause', {'reason': reason}, "Goal paused".tr);
    }
  }

  Future<void> _resume() async {
    final reason = await confirmAction(
      title: "Resume goal?".tr,
      message:
          "The goal becomes active again and the missed-installment count resets."
              .tr,
      confirmLabel: "Resume".tr,
    );
    if (reason != null) _controller.act('resume', {}, "Goal resumed".tr);
  }

  Future<void> _reschedule(GoalDetail goal) async {
    final body = await Get.dialog<Map<String, dynamic>>(
      RescheduleDialog(goal: goal),
    );
    if (body != null) {
      _controller.act('reschedule', body, "Trip rescheduled".tr);
    }
  }

  Future<void> _cancel(GoalDetail goal) async {
    final quote = goal.cancellation_quote;
    final reason = await confirmAction(
      title: "Cancel goal?".tr,
      message:
          "This can't be undone. Any refund is sent automatically to the customer."
              .tr,
      confirmLabel: "Cancel goal".tr,
      destructive: true,
      reasonLabel: "Reason".tr,
      reasonRequired: true,
      extra: quote == null
          ? null
          : InfoGrid(
              itemWidth: 180,
              children: [
                InfoRow(
                  label: "Refund".tr,
                  value: "@amount (@pct%)".trParams({
                    'amount': quote.refund.formatted,
                    'pct': '${quote.refund_percentage}',
                  }),
                ),
                InfoRow(label: "Processing fee".tr, value: quote.fee.formatted),
                InfoRow(label: "Policy".tr, value: quote.policy),
              ],
            ),
    );
    if (reason != null) {
      _controller.act('cancel', {'reason': reason}, "Goal cancelled".tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Goal".tr)),
      body: Obx(() {
        final goal = _controller.goal.value;
        if (goal == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final busy = _controller.isActing.value;
        final currency = Currency.fromCode(goal.currency);
        Money m(int minor) => Money(minor, currency);

        return PageBody(
          title: goal.title,
          subtitle: goal.itinerary_title,
          actions: [
            StatusChip.goal(goal.status),
            if (goal.booking_uuid != null)
              OutlinedButton.icon(
                onPressed: () =>
                    _shell.open(BookingDetailsScreen(uuid: goal.booking_uuid!)),
                icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                label: Text("Booking".tr),
              ),
            PermissionGate(
              code: 'goals.manage',
              child: Wrap(
                spacing: 8,
                children: [
                  if (goal.status == GoalStatus.active)
                    OutlinedButton(
                      onPressed: busy ? null : () => _pause(goal),
                      child: Text("Pause".tr),
                    ),
                  if (goal.status == GoalStatus.paused)
                    OutlinedButton(
                      onPressed: busy ? null : _resume,
                      child: Text("Resume".tr),
                    ),
                  if (_reschedulable.contains(goal.status))
                    OutlinedButton(
                      onPressed: busy ? null : () => _reschedule(goal),
                      child: Text("Reschedule".tr),
                    ),
                  if (_cancellable.contains(goal.status))
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: busy ? null : () => _cancel(goal),
                      child: Text("Cancel goal".tr),
                    ),
                ],
              ),
            ),
          ],
          children: [
            SectionCard(
              title: "Summary".tr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 360, child: GoalProgress(goal: goal)),
                  const SizedBox(height: 16),
                  InfoGrid(
                    children: [
                      InfoRow(
                        label: "Customer".tr,
                        child: InkWell(
                          onTap: () => _shell.open(
                            UserDetailsScreen(uuid: goal.user.uuid),
                          ),
                          child: Text(
                            goal.user.displayName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      InfoRow(label: "Phone".tr, value: goal.user.phone_number),
                      InfoRow(label: "Total".tr, value: goal.total.formatted),
                      InfoRow(label: "Paid".tr, value: goal.paid.formatted),
                      InfoRow(
                        label: "Remaining".tr,
                        value: goal.remaining.formattedOrZero,
                      ),
                      InfoRow(
                        label: "Deposit".tr,
                        value: m(goal.deposit_amount).formatted,
                      ),
                      InfoRow(
                        label: "Frequency".tr,
                        value: goal.frequency == PaymentFrequency.custom
                            ? "Every @n days".trParams({
                                'n': '${goal.custom_days}',
                              })
                            : goal.frequency.label,
                      ),
                      InfoRow(
                        label: "Travel date".tr,
                        value: TimeUtil.formatDate(goal.travel_date),
                      ),
                      InfoRow(
                        label: "Pay by".tr,
                        value: TimeUtil.formatDate(goal.pay_by_date),
                      ),
                      InfoRow(
                        label: "Missed in a row".tr,
                        value: '${goal.consecutive_missed}',
                      ),
                      InfoRow(
                        label: "Created".tr,
                        value: TimeUtil.formatDateTime(goal.created_at),
                      ),
                      InfoRow(
                        label: "Activated".tr,
                        value: TimeUtil.formatDateTime(goal.activated_at),
                      ),
                      if (goal.completed_at != null)
                        InfoRow(
                          label: "Completed".tr,
                          value: TimeUtil.formatDateTime(goal.completed_at),
                        ),
                      if (goal.cancellation_reason != null)
                        InfoRow(
                          label: "Cancellation reason".tr,
                          value: goal.cancellation_reason,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SectionCard(
              title: "Travellers (@n)".trParams({
                'n': '${goal.travellers.length}',
              }),
              child: SimpleTable(
                items: goal.travellers,
                headers: const ['Name', 'Age', 'Residency'],
                cells: (t) => [
                  Text(t.name),
                  Text(t.age_category.label),
                  Text(t.residency.label),
                ],
              ),
            ),
            SectionCard(
              title: "Installments".tr,
              child: SimpleTable(
                items: goal.installments,
                headers: const ['Due', 'Amount', 'Paid', 'Status', ''],
                emptyMessage: 'No schedule yet (draft)',
                cells: (i) => [
                  Text(TimeUtil.formatDate(i.due_date)),
                  Text(m(i.amount).formatted),
                  Text(m(i.amount_paid).formatted),
                  StatusChip.installment(i.status),
                  Text(i.is_deposit ? "Deposit".tr : ''),
                ],
              ),
            ),
            SectionCard(
              title: "Payments".tr,
              child: SimpleTable(
                items: goal.payments,
                headers: const [
                  'Date',
                  'Amount',
                  'Method',
                  'Status',
                  'Receipt',
                ],
                emptyMessage: 'No payments yet',
                onTap: (p) => _shell.open(PaymentDetailsScreen(uuid: p.uuid)),
                cells: (p) => [
                  Text(TimeUtil.formatDateTime(p.created_at)),
                  Text(p.money.formatted),
                  Text(p.method.label),
                  StatusChip.payment(p.status),
                  Text(p.receipt_number ?? '-'),
                ],
              ),
            ),
            if (goal.refunds.isNotEmpty)
              SectionCard(
                title: "Refunds".tr,
                child: SimpleTable(
                  items: goal.refunds,
                  headers: const [
                    'Created',
                    'Amount',
                    'Status',
                    'Attempts',
                    'Reference',
                  ],
                  cells: (r) => [
                    Text(TimeUtil.formatDateTime(r.created_at)),
                    Text(r.money.formatted),
                    StatusChip.refund(r.status),
                    Text('${r.attempts}'),
                    Text(r.provider_reference ?? '-'),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}
