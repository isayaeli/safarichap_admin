import 'package:get/get.dart';
import 'package:safarichap_admin/src/data/repositories/preferences_repository.dart';
import 'package:safarichap_admin/src/routes/app_router.dart';

import 'admin_section.dart';

/// Side-nav state and navigation. Every page has a URL (`routes/app_router.dart`):
/// [select] goes to a section's list, [open] pushes a detail or form page
/// inside the shell, so the side navigation stays.
class ShellController extends GetxController {
  final PreferenceRepository _preferenceRepository;
  ShellController(this._preferenceRepository);

  late final railExtended = _preferenceRepository.isRailExtended.obs;

  /// Tapping the current section goes back to its list too.
  void select(AdminSection section) => appRouter.go(section.path);

  /// e.g. `open(AppRoutes.customer(uuid))`. Completes when the page is closed,
  /// so a list can reload afterwards.
  Future<T?> open<T>(String location) => appRouter.push<T>(location);

  /// Closes the current detail page. A page opened straight from a link has
  /// nothing under it, so this goes to its section's list instead.
  void back<T>([T? result]) {
    if (appRouter.canPop()) {
      appRouter.pop<T>(result);
      return;
    }
    final location = appRouter.routerDelegate.currentConfiguration.uri.path;
    appRouter.go(AdminSection.fromLocation(location)?.path ?? '/');
  }

  void toggleRail() {
    railExtended.toggle();
    _preferenceRepository.setRailExtended(railExtended.value);
  }
}
