import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/utils/debouncer.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';
import 'package:safarichap_admin/src/core/components/busy_button.dart';

import 'notifications_controller.dart';

/// Compose a push + in-app notification for a group of customers. The
/// recipient count is previewed (dry run) before anything is sent.
class BroadcastDialog extends StatefulWidget {
  final BroadcastsController controller;
  const BroadcastDialog({super.key, required this.controller});

  @override
  State<BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<BroadcastDialog> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  final _uuids = TextEditingController();
  final _debouncer = Debouncer();
  BroadcastAudience _audience = BroadcastAudience.all;
  Residency _residency = Residency.resident;
  GoalStatus _goalStatus = GoalStatus.active;

  @override
  void initState() {
    super.initState();
    _preview();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _body => {
    'title': _title.text.trim().isEmpty ? '-' : _title.text.trim(),
    'message': _message.text.trim().isEmpty ? '-' : _message.text.trim(),
    'audience': _audience.wire,
    if (_audience == BroadcastAudience.residency) 'residency': _residency.wire,
    if (_audience == BroadcastAudience.goalStatus)
      'goal_status': _goalStatus.wire,
    if (_audience == BroadcastAudience.users)
      'user_uuids': _uuids.text
          .split(RegExp(r'[\s,]+'))
          .where((s) => s.isNotEmpty)
          .toList(),
  };

  void _preview() => _debouncer.run(() => widget.controller.preview(_body));

  Future<void> _send() async {
    if (_title.text.trim().isEmpty || _message.text.trim().isEmpty) return;
    final n = widget.controller.recipients.value ?? 0;
    final ok = await confirmAction(
      title: "Send to @n customers?".trParams({'n': '$n'}),
      message:
          "Each customer gets a push notification and an entry in their notifications list. This can't be recalled."
              .tr,
      confirmLabel: "Send".tr,
    );
    if (ok == null) return;
    if (await widget.controller.send(_body)) closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text("New broadcast".tr),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<BroadcastAudience>(
                initialValue: _audience,
                decoration: InputDecoration(labelText: "Audience".tr),
                items: [
                  for (final a in BroadcastAudience.values)
                    DropdownMenuItem(value: a, child: Text(a.label)),
                ],
                onChanged: (v) {
                  setState(() => _audience = v ?? _audience);
                  _preview();
                },
              ),
              const SizedBox(height: 12),
              if (_audience == BroadcastAudience.residency)
                SegmentedButton<Residency>(
                  segments: [
                    for (final r in Residency.values)
                      ButtonSegment(value: r, label: Text(r.label)),
                  ],
                  selected: {_residency},
                  onSelectionChanged: (s) {
                    setState(() => _residency = s.first);
                    _preview();
                  },
                ),
              if (_audience == BroadcastAudience.goalStatus)
                DropdownButtonFormField<GoalStatus>(
                  initialValue: _goalStatus,
                  decoration: InputDecoration(
                    labelText: "Customers with a goal that is".tr,
                  ),
                  items: [
                    for (final s in GoalStatus.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) {
                    setState(() => _goalStatus = v ?? _goalStatus);
                    _preview();
                  },
                ),
              if (_audience == BroadcastAudience.users)
                TextField(
                  controller: _uuids,
                  minLines: 2,
                  maxLines: 4,
                  onChanged: (_) => _preview(),
                  decoration: InputDecoration(
                    labelText: "Customer IDs".tr,
                    helperText:
                        "Paste customer uuids, separated by commas or new lines"
                            .tr,
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                maxLength: 120,
                decoration: InputDecoration(labelText: "Title".tr),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _message,
                minLines: 3,
                maxLines: 6,
                maxLength: 500,
                decoration: InputDecoration(labelText: "Message".tr),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                "Preview".tr,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(_title.text.isEmpty ? "Title".tr : _title.text),
                  subtitle: Text(
                    _message.text.isEmpty ? "Message".tr : _message.text,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final n = widget.controller.recipients.value;
                return Text(
                  n == null
                      ? "Counting recipients…".tr
                      : "@n customers will receive this".trParams({'n': '$n'}),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => closeDialog(), child: Text("Cancel".tr)),
        Obx(
          () => BusyButton(
            busy: widget.controller.isSending.value,
            onPressed: (widget.controller.recipients.value ?? 0) == 0
                ? null
                : _send,
            icon: Icons.send,
            label: "Send".tr,
          ),
        ),
      ],
    );
  }
}
