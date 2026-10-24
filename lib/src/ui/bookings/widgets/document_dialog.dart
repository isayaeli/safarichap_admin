import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/file_upload.dart';
import 'package:safarichap_admin/src/data/models/booking/booking.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';
import 'package:safarichap_admin/src/core/components/busy_button.dart';

import '../bookings_controller.dart';

/// Add or edit a trip document: a link/PDF (voucher, permits) or text
/// (packing list, one item per line).
class DocumentDialog extends StatefulWidget {
  final BookingDetailController controller;
  final TripDocument? document;
  const DocumentDialog({super.key, required this.controller, this.document});

  @override
  State<DocumentDialog> createState() => _DocumentDialogState();
}

class _DocumentDialogState extends State<DocumentDialog> {
  late TripDocumentType _type = widget.document?.type ?? TripDocumentType.other;
  late final _title = TextEditingController(text: widget.document?.title);
  late final _url = TextEditingController(text: widget.document?.url);
  late final _content = TextEditingController(text: widget.document?.content);
  bool _uploading = false;

  Future<void> _upload() async {
    setState(() => _uploading = true);
    final url = await pickAndUpload(
      folder: 'documents',
      extensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (!mounted) return;
    setState(() {
      _uploading = false;
      if (url != null) _url.text = url;
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    final ok = await widget.controller.saveDocument(
      documentUuid: widget.document?.uuid,
      body: {
        'type': _type.wire,
        'title': _title.text.trim(),
        'url': _url.text.trim().isEmpty ? null : _url.text.trim(),
        'content': _content.text.trim().isEmpty ? null : _content.text.trim(),
      },
    );
    if (ok) closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.document == null ? "Add document".tr : "Edit document".tr,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TripDocumentType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: "Type".tr),
                items: [
                  for (final t in TripDocumentType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                decoration: InputDecoration(labelText: "Title".tr),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _url,
                      decoration: InputDecoration(
                        labelText: "Link (optional)".tr,
                      ),
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
                          tooltip: "Upload PDF or image".tr,
                          onPressed: _upload,
                          icon: const Icon(Icons.upload_file),
                        ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: "Text (optional)".tr,
                  helperText: "Packing lists: one item per line".tr,
                ),
              ),
            ],
          ),
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
