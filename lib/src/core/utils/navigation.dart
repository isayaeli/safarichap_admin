import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Pops the open dialog, returning [result] to `Get.dialog`.
///
/// Use this instead of `Get.back()`: GetX 4's back() closes a visible snackbar
/// *instead of* the dialog, and every save shows a success snack first, so the
/// dialog would stay open.
///
/// It checks the root navigator's top route rather than `Get.isDialogOpen`,
/// which GetX doesn't keep up to date under `GetMaterialApp.router` (#4).
void closeDialog<T>([T? result]) {
  final navigator = Get.key.currentState;
  if (navigator == null) return;
  var dialogOnTop = false;
  // A predicate that's true at once pops nothing; it just reads the top route.
  navigator.popUntil((route) {
    dialogOnTop = route is PopupRoute;
    return true;
  });
  if (dialogOnTop) navigator.pop<T>(result);
}
