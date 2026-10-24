import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';

/// New travel date (and optionally frequency). The API keeps the locked price
/// and re-spreads only the remaining balance. Returns the request body.
class RescheduleDialog extends StatefulWidget {
  final GoalDetail goal;
  const RescheduleDialog({super.key, required this.goal});

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  late DateTime _date = widget.goal.travel_date.isAfter(DateTime.now())
      ? widget.goal.travel_date
      : DateTime.now().add(const Duration(days: 90));
  late PaymentFrequency _frequency = widget.goal.frequency;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Reschedule trip".tr),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "The price stays locked. Only the remaining @amount is spread over new installments, and the customer is notified."
                  .trParams({'amount': widget.goal.remaining.formattedOrZero}),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(
                "Travel date: @date".trParams({
                  'date': TimeUtil.formatDate(_date),
                }),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentFrequency>(
              initialValue: _frequency,
              decoration: InputDecoration(labelText: "Frequency".tr),
              items: [
                for (final f in PaymentFrequency.values.where(
                  (f) => f != PaymentFrequency.custom || _frequency == f,
                ))
                  DropdownMenuItem(value: f, child: Text(f.label)),
              ],
              onChanged: (v) => setState(() => _frequency = v ?? _frequency),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => closeDialog(), child: Text("Cancel".tr)),
        FilledButton(
          onPressed: () => closeDialog({
            'travel_date': _date.toApiDate(),
            'frequency': _frequency.wire,
          }),
          child: Text("Reschedule".tr),
        ),
      ],
    );
  }
}
