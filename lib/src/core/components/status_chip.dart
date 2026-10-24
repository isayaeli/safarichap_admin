import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.goal(GoalStatus status) => StatusChip(
    label: status.label,
    color: switch (status) {
      GoalStatus.active => Colors.blue,
      GoalStatus.completed => Colors.green,
      GoalStatus.paused => Colors.orange,
      GoalStatus.expired => Colors.red,
      GoalStatus.cancelled => Colors.grey,
      GoalStatus.draft => safariChapColors.tertiaryPressedColor!,
    },
  );

  factory StatusChip.installment(InstallmentStatus status) => StatusChip(
    label: status.label,
    color: switch (status) {
      InstallmentStatus.paid => Colors.green,
      InstallmentStatus.partiallyPaid => Colors.orange,
      InstallmentStatus.missed => Colors.red,
      InstallmentStatus.upcoming => safariChapColors.tertiaryPressedColor!,
    },
  );

  factory StatusChip.payment(PaymentStatus status) => StatusChip(
    label: status.label,
    color: switch (status) {
      PaymentStatus.success => Colors.green,
      PaymentStatus.pending => Colors.orange,
      PaymentStatus.failed => Colors.red,
      PaymentStatus.refunded => Colors.purple,
    },
  );

  factory StatusChip.refund(RefundStatus status) => StatusChip(
    label: status.label,
    color: switch (status) {
      RefundStatus.completed => Colors.green,
      RefundStatus.pending => Colors.orange,
      RefundStatus.processing => Colors.blue,
      RefundStatus.failed => Colors.red,
    },
  );

  factory StatusChip.kyc(KycStatus status) => StatusChip(
    label: status.label,
    color: switch (status) {
      KycStatus.verified => Colors.green,
      KycStatus.pending => Colors.orange,
      KycStatus.rejected => Colors.red,
      KycStatus.notRequired => Colors.grey,
    },
  );

  factory StatusChip.booking(BookingStatus status) => StatusChip(
    label: status.label,
    color: switch (status) {
      BookingStatus.confirmed => Colors.blue,
      BookingStatus.completed => Colors.green,
      BookingStatus.cancelled => Colors.grey,
    },
  );

  /// Active / inactive flags (accounts, trips, staff).
  factory StatusChip.active(bool active, {String? on, String? off}) =>
      StatusChip(
        label: active ? (on ?? 'Active'.tr) : (off ?? 'Inactive'.tr),
        color: active ? Colors.green : Colors.grey,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
