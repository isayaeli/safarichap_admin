import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'fx_controller.dart';

class FxScreen extends StatefulWidget {
  const FxScreen({super.key});

  @override
  State<FxScreen> createState() => _FxScreenState();
}

class _FxScreenState extends State<FxScreen> {
  final _controller = Get.put(FxController(sl()));

  @override
  void dispose() {
    Get.delete<FxController>();
    super.dispose();
  }

  void _override([String currency = 'USD']) =>
      Get.dialog(_OverrideDialog(controller: _controller, currency: currency));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final r in _controller.current)
                  SizedBox(
                    width: 240,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "1 @code =".trParams({'code': r.from_currency}),
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                            Text(
                              "TSh @rate".trParams({'rate': r.display}),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (r.isManual) ...[
                                  StatusChip(
                                    label: "Manual".tr,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: Text(
                                    timeago.format(r.fetched_at),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PermissionGate(
                                  code: 'fx.manage',
                                  child: IconButton(
                                    tooltip: "Set by hand".tr,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () => _override(r.from_currency),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () => PagedTable<AdminFxRate>(
              controller: _controller,
              searchable: false,
              emptyMessage: 'No rates yet',
              filters: [
                FilterDropdown<String>(
                  label: 'Currency',
                  value: _controller.filters['from_currency'],
                  options: const {'USD': 'USD', 'EUR': 'EUR', 'GBP': 'GBP'},
                  onChanged: (v) => _controller.setFilter('from_currency', v),
                  width: 140,
                ),
              ],
              actions: [
                PermissionGate(
                  code: 'fx.manage',
                  child: OutlinedButton.icon(
                    onPressed: _controller.isSaving.value
                        ? null
                        : _controller.fetchFromProvider,
                    icon: const Icon(Icons.cloud_download_outlined, size: 18),
                    label: Text("Fetch from provider".tr),
                  ),
                ),
                PermissionGate(
                  code: 'fx.manage',
                  child: FilledButton.icon(
                    onPressed: _override,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text("Set rate".tr),
                  ),
                ),
              ],
              columns: [
                TableColumn(
                  'Fetched',
                  (r) => Text(TimeUtil.formatDateTime(r.fetched_at)),
                  sortKey: 'fetched_at',
                ),
                TableColumn('Currency', (r) => Text(r.from_currency)),
                TableColumn(
                  'TZS per unit',
                  (r) => Text(r.display),
                  numeric: true,
                ),
                TableColumn(
                  'Exact',
                  (r) => Text(
                    '${r.numerator} / ${r.denominator}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                TableColumn(
                  'Source',
                  (r) => Text(
                    r.isManual ? "Manual".tr : r.source,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverrideDialog extends StatefulWidget {
  final FxController controller;
  final String currency;
  const _OverrideDialog({required this.controller, required this.currency});

  @override
  State<_OverrideDialog> createState() => _OverrideDialogState();
}

class _OverrideDialogState extends State<_OverrideDialog> {
  late String _currency = widget.currency;
  final _rate = TextEditingController();

  /// "2650.25" → 265025 / 100, kept exact (no floating point).
  (int, int)? _fraction(String text) {
    final m = RegExp(
      r'^(\d+)(?:\.(\d{1,4}))?$',
    ).firstMatch(text.trim().replaceAll(',', ''));
    if (m == null) return null;
    final decimals = m.group(2) ?? '';
    var den = 1;
    for (var i = 0; i < decimals.length; i++) {
      den *= 10;
    }
    final num =
        int.parse(m.group(1)!) * den +
        (decimals.isEmpty ? 0 : int.parse(decimals));
    return num == 0 ? null : (num, den);
  }

  Future<void> _save() async {
    final f = _fraction(_rate.text);
    if (f == null) return;
    if (await widget.controller.setRate(_currency, f.$1, f.$2)) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Set exchange rate".tr),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Used for new quotes and goals until the next automatic refresh (daily 06:00). Active goals keep their locked rate."
                  .tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: InputDecoration(labelText: "Currency".tr),
                    items: [
                      for (final c in const ['USD', 'EUR', 'GBP'])
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) =>
                        setState(() => _currency = v ?? _currency),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rate,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "TZS per 1 @code".trParams({
                        'code': _currency,
                      }),
                      hintText: "2650.50",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text("Cancel".tr)),
        Obx(
          () => FilledButton(
            onPressed: widget.controller.isSaving.value ? null : _save,
            child: Text("Save".tr),
          ),
        ),
      ],
    );
  }
}
