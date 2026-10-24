import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/goals/goal_details_screen.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
import 'package:safarichap_admin/src/ui/users/user_details_screen.dart';

import 'payments_controller.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String uuid;
  const PaymentDetailsScreen({super.key, required this.uuid});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  // Unique per page: the same record can be open twice (customer → goal → customer).
  late final _tag = '${widget.uuid}#${identityHashCode(this)}';
  late final _controller = Get.put(
    PaymentDetailController(sl(), widget.uuid),
    tag: _tag,
  );
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<PaymentDetailController>(tag: _tag);
    super.dispose();
  }

  Future<void> _reconcile() async {
    final ok = await confirmAction(
      title: "Check with the provider?".tr,
      message:
          "Asks the provider for this payment's status now. If it succeeded, it's applied to the goal; if the timeout has passed without confirmation, it's marked failed."
              .tr,
      confirmLabel: "Check now".tr,
    );
    if (ok != null) _controller.reconcile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment".tr)),
      body: Obx(() {
        final p = _controller.payment.value;
        if (p == null) return const Center(child: CircularProgressIndicator());
        final link = TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        );
        return PageBody(
          title: p.money.formatted,
          subtitle: p.order_reference,
          actions: [
            StatusChip.payment(p.status),
            if (p.status == PaymentStatus.pending)
              PermissionGate(
                code: 'payments.reconcile',
                child: FilledButton.icon(
                  onPressed: _controller.isReconciling.value
                      ? null
                      : _reconcile,
                  icon: const Icon(Icons.sync, size: 18),
                  label: Text("Reconcile".tr),
                ),
              ),
          ],
          children: [
            SectionCard(
              title: "Details".tr,
              child: InfoGrid(
                children: [
                  InfoRow(
                    label: "Customer".tr,
                    child: InkWell(
                      onTap: () =>
                          _shell.open(UserDetailsScreen(uuid: p.user.uuid)),
                      child: Text(p.user.displayName, style: link),
                    ),
                  ),
                  InfoRow(
                    label: "Goal".tr,
                    child: InkWell(
                      onTap: () =>
                          _shell.open(GoalDetailsScreen(uuid: p.goal_uuid)),
                      child: Text(p.goal_title, style: link),
                    ),
                  ),
                  InfoRow(label: "Method".tr, value: p.method.label),
                  InfoRow(label: "Phone".tr, value: p.phone_number),
                  InfoRow(label: "Provider".tr, value: p.provider),
                  InfoRow(
                    label: "Provider reference".tr,
                    value: p.provider_reference,
                  ),
                  InfoRow(
                    label: "Provider transaction".tr,
                    value: p.provider_txn_id,
                  ),
                  InfoRow(label: "Receipt".tr, value: p.receipt_number),
                  InfoRow(
                    label: "Started".tr,
                    value: TimeUtil.formatDateTime(p.created_at),
                  ),
                  InfoRow(
                    label: "Settled".tr,
                    value: TimeUtil.formatDateTime(p.settled_at),
                  ),
                  if (p.failure_reason != null)
                    InfoRow(
                      label: "Failure reason".tr,
                      value: p.failure_reason,
                    ),
                ],
              ),
            ),
            PermissionGate(
              code: 'payments.view_raw',
              child: SectionCard(
                title: "Provider webhook".tr,
                child: p.raw_webhook == null
                    ? Text("No webhook received".tr)
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          const JsonEncoder.withIndent(
                            '  ',
                          ).convert(p.raw_webhook),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
