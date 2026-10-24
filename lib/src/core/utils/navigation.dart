import 'package:get/get.dart';

/// Pops the open dialog, returning [result] to `Get.dialog`.
///
/// Use this instead of `Get.back()`: GetX 4's back() closes a visible snackbar
/// *instead of* the dialog, and every save shows a success snack first, so the
/// dialog would stay open.
void closeDialog<T>([T? result]) {
  if (Get.isDialogOpen ?? false) Get.key.currentState?.pop<T>(result);
}
