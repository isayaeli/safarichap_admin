import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/data/repositories/preferences_repository.dart';

import 'admin_section.dart';

/// Selected section and the content-area navigator. Detail and form pages
/// open inside the content area with [open] so the side navigation stays.
class ShellController extends GetxController {
  final PreferenceRepository _preferenceRepository;
  ShellController(this._preferenceRepository);

  static const navigatorId = 1;

  final section = AdminSection.overview.obs;
  late final railExtended = _preferenceRepository.isRailExtended.obs;

  void select(AdminSection value) {
    if (section.value == value) {
      // Tapping the current section goes back to its list.
      Get.nestedKey(navigatorId)?.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    // Leave any open detail page, then show the new section's list.
    Get.nestedKey(navigatorId)?.currentState?.popUntil((r) => r.isFirst);
    section.value = value;
  }

  void toggleRail() {
    railExtended.toggle();
    _preferenceRepository.setRailExtended(railExtended.value);
  }

  Future<T?>? open<T>(Widget page) => Get.to<T>(
    () => page,
    id: navigatorId,
    transition: Transition.fadeIn,
    duration: 150.milliseconds,
  );

  /// Not `Get.back(id:)`: that closes a visible snackbar instead of the page.
  void back<T>([T? result]) =>
      Get.keys[navigatorId]?.currentState?.maybePop<T>(result);
}
