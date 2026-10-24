import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Asks before an action. Returns null when cancelled, otherwise the typed
/// reason ('' when [reasonLabel] is null). With [reasonRequired] the confirm
/// button stays disabled until a reason is typed.
Future<String?> confirmAction({
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
  String? reasonLabel,
  bool reasonRequired = false,
  Widget? extra,
}) {
  final reason = TextEditingController();
  return Get.dialog<String>(
    StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        final canConfirm = !reasonRequired || reason.text.trim().isNotEmpty;
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
                if (extra != null) ...[const SizedBox(height: 12), extra],
                if (reasonLabel != null) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: reason,
                    maxLines: 3,
                    minLines: 2,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(labelText: reasonLabel),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel".tr)),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    )
                  : null,
              onPressed: canConfirm
                  ? () => Get.back(result: reason.text.trim())
                  : null,
              child: Text(confirmLabel ?? "Confirm".tr),
            ),
          ],
        );
      },
    ),
  );
}

/// One text input in a dialog (e.g. a payout reference). Null when cancelled.
Future<String?> promptText({
  required String title,
  required String label,
  String? message,
  String initial = '',
  String? confirmLabel,
}) {
  final text = TextEditingController(text: initial);
  return Get.dialog<String>(
    AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[Text(message), const SizedBox(height: 12)],
            TextField(
              controller: text,
              autofocus: true,
              decoration: InputDecoration(labelText: label),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text("Cancel".tr)),
        FilledButton(
          onPressed: () {
            if (text.text.trim().isNotEmpty) Get.back(result: text.text.trim());
          },
          child: Text(confirmLabel ?? "Save".tr),
        ),
      ],
    ),
  );
}
