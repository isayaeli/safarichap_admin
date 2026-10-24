import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/confirm_dialog.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/safari_image.dart';
import 'package:safarichap_admin/src/core/utils/file_upload.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';
import 'package:safarichap_admin/src/core/components/busy_button.dart';

import '../catalogue_controller.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final _controller = Get.put(
    CatalogueController<Destination>(
      sl(),
      CatalogueRepository.destinations,
      Destination.fromJson,
    ),
    tag: CatalogueRepository.destinations,
  );

  @override
  void dispose() {
    Get.delete<CatalogueController<Destination>>(
      tag: CatalogueRepository.destinations,
    );
    super.dispose();
  }

  void _edit([Destination? d]) {
    if (!can('catalogue.manage')) return;
    Get.dialog(_DestinationDialog(controller: _controller, destination: d));
  }

  Future<void> _delete(Destination d) async {
    final ok = await confirmAction(
      title: "Delete destination?".tr,
      message: "@name is removed from every trip that lists it.".trParams({
        'name': d.name,
      }),
      confirmLabel: "Delete".tr,
      destructive: true,
    );
    if (ok != null) _controller.delete(d.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return PagedTable<Destination>(
      controller: _controller,
      searchHint: 'Name or region',
      emptyMessage: 'No destinations yet',
      onTap: _edit,
      actions: [
        PermissionGate(
          code: 'catalogue.manage',
          child: FilledButton.icon(
            onPressed: _edit,
            icon: const Icon(Icons.add, size: 18),
            label: Text("New destination".tr),
          ),
        ),
      ],
      columns: [
        TableColumn(
          '',
          (d) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: d.image.isEmpty
                ? const SizedBox(
                    width: 56,
                    height: 40,
                    child: Icon(Icons.image_not_supported_outlined),
                  )
                : SafariImage(url: d.image, width: 56, height: 40),
          ),
          fixedWidth: 80,
        ),
        TableColumn(
          'Name',
          (d) =>
              Text(d.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          size: ColumnSize.L,
          sortKey: 'name',
        ),
        TableColumn('Region', (d) => Text(d.region.isEmpty ? '-' : d.region)),
        TableColumn(
          'Trips',
          (d) => Text('${d.itineraries_count}'),
          numeric: true,
          size: ColumnSize.S,
          sortKey: 'itineraries_count',
        ),
        TableColumn(
          '',
          (d) => PermissionGate(
            code: 'catalogue.manage',
            child: IconButton(
              tooltip: "Delete".tr,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(d),
            ),
          ),
          fixedWidth: 60,
        ),
      ],
    );
  }
}

class _DestinationDialog extends StatefulWidget {
  final CatalogueController<Destination> controller;
  final Destination? destination;
  const _DestinationDialog({required this.controller, this.destination});

  @override
  State<_DestinationDialog> createState() => _DestinationDialogState();
}

class _DestinationDialogState extends State<_DestinationDialog> {
  late final _name = TextEditingController(text: widget.destination?.name);
  late final _region = TextEditingController(text: widget.destination?.region);
  late final _image = TextEditingController(text: widget.destination?.image);
  bool _uploading = false;

  Future<void> _upload() async {
    setState(() => _uploading = true);
    final url = await pickAndUpload(folder: 'destinations');
    if (!mounted) return;
    setState(() {
      _uploading = false;
      if (url != null) _image.text = url;
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final ok = await widget.controller.save(
      uuid: widget.destination?.uuid,
      body: {
        'name': _name.text.trim(),
        'region': _region.text.trim(),
        'image': _image.text.trim(),
      },
    );
    if (ok) closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.destination == null
            ? "New destination".tr
            : "Edit destination".tr,
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: "Name".tr),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _region,
              decoration: InputDecoration(
                labelText: "Region".tr,
                hintText: "Northern circuit".tr,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _image,
                    decoration: InputDecoration(labelText: "Image URL".tr),
                  ),
                ),
                const SizedBox(width: 8),
                _uploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: "Upload image".tr,
                        onPressed: _upload,
                        icon: const Icon(Icons.upload),
                      ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => closeDialog(), child: Text("Cancel".tr)),
        Obx(
          () => BusyButton(
            busy: widget.controller.isSaving.value,
            onPressed: _save,
            label: "Save".tr,
          ),
        ),
      ],
    );
  }
}
