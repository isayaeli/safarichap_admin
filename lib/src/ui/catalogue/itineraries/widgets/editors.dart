import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/safari_image.dart';
import 'package:safarichap_admin/src/core/utils/file_upload.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';

/// Ordered image URLs; the first is the cover. Upload or paste a URL.
class ImagesEditor extends StatefulWidget {
  final List<String> images;
  final ValueChanged<List<String>> onChanged;
  const ImagesEditor({
    super.key,
    required this.images,
    required this.onChanged,
  });

  @override
  State<ImagesEditor> createState() => _ImagesEditorState();
}

class _ImagesEditorState extends State<ImagesEditor> {
  final _url = TextEditingController();
  bool _uploading = false;

  void _add(String url) {
    if (url.trim().isEmpty) return;
    widget.onChanged([...widget.images, url.trim()]);
    _url.clear();
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    final url = await pickAndUpload(folder: 'itineraries');
    if (!mounted) return;
    setState(() => _uploading = false);
    if (url != null) _add(url);
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (i, url) in images.indexed)
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SafariImage(
                          url: url,
                          width: 160,
                          height: 104,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        if (i == 0)
                          Positioned(
                            left: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Cover".tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: "Make cover".tr,
                          visualDensity: VisualDensity.compact,
                          onPressed: i == 0
                              ? null
                              : () => widget.onChanged([
                                  url,
                                  ...images.where((u) => u != url),
                                ]),
                          icon: const Icon(Icons.star_outline, size: 18),
                        ),
                        IconButton(
                          tooltip: "Remove".tr,
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              widget.onChanged([...images]..removeAt(i)),
                          icon: const Icon(Icons.delete_outline, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _url,
                onSubmitted: _add,
                decoration: InputDecoration(
                  labelText: "Image URL".tr,
                  hintText: "https://…",
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: () => _add(_url.text), child: Text("Add".tr)),
            _uploading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: _upload,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text("Upload".tr),
                  ),
          ],
        ),
      ],
    );
  }
}

/// Ordered destinations (the first is the main one) picked from the catalogue.
class DestinationsPicker extends StatelessWidget {
  final List<Destination> all;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const DestinationsPicker({
    super.key,
    required this.all,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final byUuid = {for (final d in all) d.uuid: d};
    final available = all.where((d) => !selected.contains(d.uuid)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected.isEmpty)
          Text(
            "No destinations yet".tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ReorderableListView(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: (from, to) {
            final list = [...selected];
            list.insert(to, list.removeAt(from));
            onChanged(list);
          },
          children: [
            for (final (i, uuid) in selected.indexed)
              ListTile(
                key: ValueKey(uuid),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: ReorderableDragStartListener(
                  index: i,
                  child: const Icon(Icons.drag_indicator),
                ),
                title: Text(byUuid[uuid]?.name ?? uuid),
                subtitle: Text(
                  i == 0 ? "Main destination".tr : (byUuid[uuid]?.region ?? ''),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onChanged([...selected]..remove(uuid)),
                ),
              ),
          ],
        ),
        if (available.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: (uuid) => onChanged([...selected, uuid]),
            itemBuilder: (_) => [
              for (final d in available)
                PopupMenuItem(value: d.uuid, child: Text(d.name)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 6),
                  Text("Add destination".tr),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Day-by-day plan. Days are renumbered 1..n on every change.
class DaysEditor extends StatelessWidget {
  final List<ItineraryDay> days;
  final VoidCallback onChanged;
  const DaysEditor({super.key, required this.days, required this.onChanged});

  void _renumber() {
    for (final (i, d) in days.indexed) {
      d.day_number = i + 1;
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, day) in days.indexed)
          Padding(
            key: ObjectKey(day),
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: day.title,
                            decoration: InputDecoration(labelText: "Title".tr),
                            onChanged: (v) => day.title = v,
                          ),
                        ),
                        IconButton(
                          tooltip: "Move up".tr,
                          onPressed: i == 0
                              ? null
                              : () {
                                  days.insert(i - 1, days.removeAt(i));
                                  _renumber();
                                },
                          icon: const Icon(Icons.arrow_upward, size: 18),
                        ),
                        IconButton(
                          tooltip: "Remove".tr,
                          onPressed: () {
                            days.removeAt(i);
                            _renumber();
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: day.location,
                            decoration: InputDecoration(
                              labelText: "Location".tr,
                            ),
                            onChanged: (v) => day.location = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: day.accommodation,
                            decoration: InputDecoration(
                              labelText: "Accommodation".tr,
                            ),
                            onChanged: (v) => day.accommodation = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: day.description,
                      minLines: 2,
                      maxLines: 5,
                      decoration: InputDecoration(labelText: "Description".tr),
                      onChanged: (v) => day.description = v,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text("Meals:".tr),
                        for (final meal in const [
                          'breakfast',
                          'lunch',
                          'dinner',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: StatefulBuilder(
                              builder: (context, setState) => FilterChip(
                                label: Text(meal.capitalizeFirst!.tr),
                                selected: day.meals.contains(meal),
                                onSelected: (on) => setState(
                                  () => on
                                      ? day.meals.add(meal)
                                      : day.meals.remove(meal),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              days.add(ItineraryDay(day_number: days.length + 1, title: ''));
              onChanged();
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text("Add day".tr),
          ),
        ),
      ],
    );
  }
}

/// Seasonal price adjustments: inclusive date ranges with a multiplier
/// (shown as ±%, stored as basis points: 12000 = +20%).
class SeasonsEditor extends StatelessWidget {
  final List<SeasonalAdjustment> seasons;
  final VoidCallback onChanged;
  const SeasonsEditor({
    super.key,
    required this.seasons,
    required this.onChanged,
  });

  Future<void> _pickRange(BuildContext context, SeasonalAdjustment s) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: s.start_date, end: s.end_date),
    );
    if (range == null) return;
    s.start_date = range.start;
    s.end_date = range.end;
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in seasons.indexed)
          Padding(
            key: ObjectKey(s),
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: s.label,
                    decoration: InputDecoration(
                      labelText: "Label".tr,
                      hintText: "High season".tr,
                    ),
                    onChanged: (v) => s.label = v,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickRange(context, s),
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    '${TimeUtil.formatDate(s.start_date)} – ${TimeUtil.formatDate(s.end_date)}',
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 130,
                  child: TextFormField(
                    initialValue: ((s.multiplier_bps - 10000) / 100).toString(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Change %".tr,
                      helperText: "+20 or -10",
                    ),
                    onChanged: (v) {
                      final pct = double.tryParse(v.trim());
                      if (pct != null) {
                        s.multiplier_bps = 10000 + (pct * 100).round();
                      }
                    },
                  ),
                ),
                IconButton(
                  tooltip: "Remove".tr,
                  onPressed: () {
                    seasons.removeAt(i);
                    onChanged();
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final now = DateTime.now();
              seasons.add(
                SeasonalAdjustment(
                  start_date: DateTime(now.year, 6, 1),
                  end_date: DateTime(now.year, 10, 31),
                  multiplier_bps: 12000,
                  label: '',
                ),
              );
              onChanged();
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text("Add season".tr),
          ),
        ),
      ],
    );
  }
}
