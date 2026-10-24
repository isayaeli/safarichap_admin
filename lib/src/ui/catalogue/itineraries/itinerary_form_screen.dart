import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/money.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'itinerary_form_controller.dart';
import 'widgets/editors.dart';

/// Create or edit a trip. Saving sends the whole trip (days, destinations,
/// pricing and seasons replace what's stored). Active goals keep the price
/// they locked at activation.
class ItineraryFormScreen extends StatefulWidget {
  final String? uuid;
  const ItineraryFormScreen({super.key, this.uuid});

  @override
  State<ItineraryFormScreen> createState() => _ItineraryFormScreenState();
}

class _ItineraryFormScreenState extends State<ItineraryFormScreen> {
  late final _tag = widget.uuid ?? 'new';
  late final _controller = Get.put(
    ItineraryFormController(sl(), widget.uuid),
    tag: _tag,
  );
  final ShellController _shell = Get.find();
  final _formKey = GlobalKey<FormState>();
  late final bool _canEdit = can('catalogue.manage');

  // Form state, filled once the trip (or the new-trip defaults) is ready.
  bool _ready = false;
  final _title = TextEditingController();
  final _slug = TextEditingController();
  final _summary = TextEditingController();
  final _duration = TextEditingController(text: '3');
  final _lead = TextEditingController();
  final _minGroup = TextEditingController(text: '1');
  final _maxGroup = TextEditingController(text: '10');
  final _sortOrder = TextEditingController(text: '0');
  final _inclusions = TextEditingController();
  final _exclusions = TextEditingController();
  AccommodationLevel _level = AccommodationLevel.midRange;
  String? _operator;
  bool _active = false;
  bool _featured = false;
  bool _kyc = false;
  bool _slugTouched = false;
  List<String> _images = [];
  List<String> _destinations = [];
  List<ItineraryDay> _days = [];
  Currency _baseCurrency = Currency.tzs;
  final _prices = {
    'resident_adult': TextEditingController(),
    'resident_child': TextEditingController(),
    'non_resident_adult': TextEditingController(),
    'non_resident_child': TextEditingController(),
  };
  List<SeasonalAdjustment> _seasons = [];

  @override
  void initState() {
    super.initState();
    ever(_controller.isLoading, (loading) {
      if (!loading && !_ready) _fill(_controller.itinerary.value);
    });
    if (!_controller.isLoading.value) _fill(_controller.itinerary.value);
  }

  @override
  void dispose() {
    Get.delete<ItineraryFormController>(tag: _tag);
    super.dispose();
  }

  void _fill(ItineraryDetail? t) {
    if (!mounted) return;
    setState(() {
      _ready = true;
      if (t == null) return;
      _title.text = t.title;
      _slug.text = t.slug;
      _slugTouched = true;
      _summary.text = t.summary;
      _duration.text = '${t.duration_days}';
      _lead.text = t.lead_time_days?.toString() ?? '';
      _minGroup.text = '${t.min_group_size}';
      _maxGroup.text = '${t.max_group_size}';
      _sortOrder.text = '${t.sort_order}';
      _inclusions.text = t.inclusions.join('\n');
      _exclusions.text = t.exclusions.join('\n');
      _level = t.accommodation_level;
      _operator = t.operator;
      _active = t.is_active;
      _featured = t.is_featured;
      _kyc = t.kyc_required;
      _images = [...t.images];
      _destinations = [...t.destinations];
      _days = [for (final d in t.days) ItineraryDay.fromJson(d.toJson())];
      _baseCurrency = Currency.fromCode(t.pricing.base_currency);
      final p = t.pricing;
      _prices['resident_adult']!.text = MoneyFormatter.toInput(
        Money(p.resident_adult, _baseCurrency),
      );
      _prices['resident_child']!.text = MoneyFormatter.toInput(
        Money(p.resident_child, _baseCurrency),
      );
      _prices['non_resident_adult']!.text = MoneyFormatter.toInput(
        Money(p.non_resident_adult, _baseCurrency),
      );
      _prices['non_resident_child']!.text = MoneyFormatter.toInput(
        Money(p.non_resident_child, _baseCurrency),
      );
      _seasons = [
        for (final s in p.seasonal_adjustments)
          SeasonalAdjustment(
            start_date: s.start_date,
            end_date: s.end_date,
            multiplier_bps: s.multiplier_bps,
            label: s.label,
          ),
      ];
    });
  }

  String _slugify(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  List<String> _lines(TextEditingController c) => c.text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      showErrorSnack("Check the highlighted fields".tr);
      return;
    }
    final prices = <String, int>{};
    for (final e in _prices.entries) {
      final money = MoneyFormatter.parse(e.value.text, _baseCurrency);
      if (money == null) {
        showErrorSnack("Enter every price".tr);
        return;
      }
      prices[e.key] = money.minor;
    }
    if (_seasons.any((s) => s.label.trim().isEmpty)) {
      showErrorSnack("Give every season a label".tr);
      return;
    }
    final saved = await _controller.save({
      'title': _title.text.trim(),
      'slug': _slug.text.trim(),
      'summary': _summary.text.trim(),
      'duration_days': int.parse(_duration.text.trim()),
      'accommodation_level': _level.wire,
      'operator': _operator,
      'lead_time_days': int.tryParse(_lead.text.trim()),
      'min_group_size': int.parse(_minGroup.text.trim()),
      'max_group_size': int.parse(_maxGroup.text.trim()),
      'sort_order': int.tryParse(_sortOrder.text.trim()) ?? 0,
      'is_active': _active,
      'is_featured': _featured,
      'kyc_required': _kyc,
      'images': _images,
      'inclusions': _lines(_inclusions),
      'exclusions': _lines(_exclusions),
      'destinations': _destinations,
      'days': [
        for (final d in _days.where((d) => d.title.trim().isNotEmpty))
          {...d.toJson(), 'title': d.title.trim()},
      ],
      'pricing': {
        'base_currency': _baseCurrency.code,
        ...prices,
        'seasonal_adjustments': [for (final s in _seasons) s.toJson()],
      },
    });
    if (saved && widget.uuid == null) _shell.back();
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      title: "Delete trip?".tr,
      message:
          "Trips that customers are saving for can't be deleted. Hide them instead."
              .tr,
      confirmLabel: "Delete".tr,
      destructive: true,
    );
    if (ok != null && await _controller.delete()) _shell.back();
  }

  String? _requiredInt(String? v, {int min = 0}) {
    final n = int.tryParse((v ?? '').trim());
    return n == null || n < min
        ? "Whole number ≥ @min".trParams({'min': '$min'})
        : null;
  }

  Widget _row(List<Widget> children) => LayoutBuilder(
    builder: (context, c) => c.maxWidth < 640
        ? Column(
            children: [
              for (final w in children)
                Padding(padding: const EdgeInsets.only(bottom: 12), child: w),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, w) in children.indexed) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: w),
              ],
            ],
          ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.uuid == null ? "New trip".tr : "Edit trip".tr),
        actions: [
          if (widget.uuid != null)
            PermissionGate(
              code: 'catalogue.manage',
              child: TextButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text("Delete".tr),
              ),
            ),
          PermissionGate(
            code: 'catalogue.manage',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Obx(
                () => FilledButton.icon(
                  onPressed: _controller.isSaving.value || !_ready
                      ? null
                      : _save,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text("Save".tr),
                ),
              ),
            ),
          ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : AbsorbPointer(
              absorbing: !_canEdit,
              child: Form(
                key: _formKey,
                child: PageBody(
                  maxWidth: 1000,
                  children: [
                    if (widget.uuid != null &&
                        (_controller.itinerary.value?.goals_count ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "@n goals use this trip. Price changes apply to new goals only; active goals keep their locked price."
                              .trParams({
                                'n':
                                    '${_controller.itinerary.value!.goals_count}',
                              }),
                        ),
                      ),
                    SectionCard(
                      title: "Basics".tr,
                      child: Column(
                        children: [
                          _row([
                            TextFormField(
                              controller: _title,
                              decoration: InputDecoration(
                                labelText: "Title".tr,
                              ),
                              onChanged: (v) {
                                if (!_slugTouched) _slug.text = _slugify(v);
                              },
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? "Required".tr
                                  : null,
                            ),
                            TextFormField(
                              controller: _slug,
                              decoration: InputDecoration(
                                labelText: "Slug".tr,
                                helperText: "Unique, used in links".tr,
                              ),
                              onChanged: (_) => _slugTouched = true,
                              validator: (v) =>
                                  RegExp(
                                    r'^[a-z0-9-]+$',
                                  ).hasMatch((v ?? '').trim())
                                  ? null
                                  : "Lowercase letters, numbers and dashes".tr,
                            ),
                          ]),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _summary,
                            minLines: 2,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: "Summary".tr,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _row([
                            Obx(
                              () => DropdownButtonFormField<String>(
                                initialValue: _operator,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "Operator".tr,
                                ),
                                items: [
                                  for (final o in _controller.operators)
                                    DropdownMenuItem(
                                      value: o.uuid,
                                      child: Text(o.name),
                                    ),
                                ],
                                onChanged: (v) => setState(() => _operator = v),
                                validator: (v) =>
                                    v == null ? "Required".tr : null,
                              ),
                            ),
                            DropdownButtonFormField<AccommodationLevel>(
                              initialValue: _level,
                              decoration: InputDecoration(
                                labelText: "Accommodation".tr,
                              ),
                              items: [
                                for (final a in AccommodationLevel.values)
                                  DropdownMenuItem(
                                    value: a,
                                    child: Text(a.label),
                                  ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _level = v ?? _level),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          _row([
                            TextFormField(
                              controller: _duration,
                              decoration: InputDecoration(labelText: "Days".tr),
                              validator: (v) => _requiredInt(v, min: 1),
                            ),
                            TextFormField(
                              controller: _minGroup,
                              decoration: InputDecoration(
                                labelText: "Min travellers".tr,
                              ),
                              validator: (v) => _requiredInt(v, min: 1),
                            ),
                            TextFormField(
                              controller: _maxGroup,
                              decoration: InputDecoration(
                                labelText: "Max travellers".tr,
                              ),
                              validator: (v) => _requiredInt(v, min: 1),
                            ),
                            TextFormField(
                              controller: _lead,
                              decoration: InputDecoration(
                                labelText: "Lead time (days)".tr,
                                helperText: "Empty = operator's".tr,
                              ),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? null
                                  : _requiredInt(v),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: "Visibility".tr,
                      child: Wrap(
                        spacing: 24,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Switch(
                            label: "Published in the app".tr,
                            value: _active,
                            onChanged: (v) => setState(() => _active = v),
                          ),
                          _Switch(
                            label: "Featured".tr,
                            value: _featured,
                            onChanged: (v) => setState(() => _featured = v),
                          ),
                          _Switch(
                            label: "Ask travellers for ID (KYC)".tr,
                            value: _kyc,
                            onChanged: (v) => setState(() => _kyc = v),
                          ),
                          SizedBox(
                            width: 140,
                            child: TextFormField(
                              controller: _sortOrder,
                              decoration: InputDecoration(
                                labelText: "Sort order".tr,
                                helperText: "Lower first".tr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: "Photos".tr,
                      child: ImagesEditor(
                        images: _images,
                        onChanged: (v) => setState(() => _images = v),
                      ),
                    ),
                    SectionCard(
                      title: "Destinations".tr,
                      child: Obx(
                        () => DestinationsPicker(
                          all: _controller.destinations.toList(),
                          selected: _destinations,
                          onChanged: (v) => setState(() => _destinations = v),
                        ),
                      ),
                    ),
                    SectionCard(
                      title: "Pricing per person".tr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<Currency>(
                              initialValue: _baseCurrency,
                              decoration: InputDecoration(
                                labelText: "Base currency".tr,
                                helperText:
                                    "Converted at today's FX for other currencies"
                                        .tr,
                              ),
                              items: [
                                for (final c in Currency.values)
                                  DropdownMenuItem(
                                    value: c,
                                    child: Text(c.code),
                                  ),
                              ],
                              onChanged: (v) => setState(
                                () => _baseCurrency = v ?? _baseCurrency,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _row([
                            _PriceField(
                              controller: _prices['resident_adult']!,
                              label: "Resident adult".tr,
                              currency: _baseCurrency,
                            ),
                            _PriceField(
                              controller: _prices['resident_child']!,
                              label: "Resident child".tr,
                              currency: _baseCurrency,
                            ),
                          ]),
                          const SizedBox(height: 12),
                          _row([
                            _PriceField(
                              controller: _prices['non_resident_adult']!,
                              label: "Non-resident adult".tr,
                              currency: _baseCurrency,
                            ),
                            _PriceField(
                              controller: _prices['non_resident_child']!,
                              label: "Non-resident child".tr,
                              currency: _baseCurrency,
                            ),
                          ]),
                          const SizedBox(height: 20),
                          Text(
                            "Seasons".tr,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          SeasonsEditor(
                            seasons: _seasons,
                            onChanged: () => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    SectionCard(
                      title: "What's included".tr,
                      child: _row([
                        TextFormField(
                          controller: _inclusions,
                          minLines: 4,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: "Included (one per line)".tr,
                          ),
                        ),
                        TextFormField(
                          controller: _exclusions,
                          minLines: 4,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: "Not included (one per line)".tr,
                          ),
                        ),
                      ]),
                    ),
                    SectionCard(
                      title: "Day by day".tr,
                      child: DaysEditor(
                        days: _days,
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Switch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Switch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Currency currency;
  const _PriceField({
    required this.controller,
    required this.label,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '${currency.symbol} ',
      ),
      validator: (v) => MoneyFormatter.parse(v ?? '', currency) == null
          ? (currency.decimals == 0
                ? "Whole amount".tr
                : "Up to @n decimals".trParams({'n': '${currency.decimals}'}))
          : null,
    );
  }
}
