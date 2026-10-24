import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';

class RolesController extends GetxController {
  final AccessRepository _accessRepository;
  final SessionController _session;
  RolesController(this._accessRepository, this._session);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final roles = <Role>[].obs;
  final permissions = <AdminPermission>[].obs;

  /// uuid of the role open in the editor; null = creating a new role.
  final selected = RxnString();
  final creating = false.obs;

  Map<String, List<AdminPermission>> get groupedPermissions {
    final groups = <String, List<AdminPermission>>{};
    for (final p in permissions) {
      groups.putIfAbsent(p.group, () => []).add(p);
    }
    return groups;
  }

  Role? get selectedRole =>
      roles.firstWhereOrNull((r) => r.uuid == selected.value);

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    isLoading.value = true;
    final results = await Future.wait([
      _accessRepository.retrieveRoles(),
      _accessRepository.retrievePermissions(),
    ]);
    isLoading.value = false;
    if (results[0] is Success) {
      roles.assignAll((results[0] as Success).data as List<Role>);
      if (selected.value == null && !creating.value && roles.isNotEmpty) {
        selected.value = roles.first.uuid;
      }
    }
    if (results[1] is Success) {
      permissions.assignAll(
        (results[1] as Success).data as List<AdminPermission>,
      );
    }
    for (final r in results) {
      if (r is Fail) showErrorSnack((r as Fail).message);
    }
  }

  void select(String uuid) {
    creating.value = false;
    selected.value = uuid;
  }

  void startNew() {
    selected.value = null;
    creating.value = true;
  }

  Future<void> save({
    String? uuid,
    required String name,
    required String description,
    required Set<String> codes,
  }) async {
    await _accessRepository
        .saveRole(
          uuid: uuid,
          body: {
            'name': name,
            'description': description,
            'permissions': codes.toList(),
          },
        )
        .execute((result) async {
          isSaving.value = result is Loading;
          if (result is Success) {
            final role = result.data as Role;
            showSuccessSnack("Role saved".tr);
            creating.value = false;
            selected.value = role.uuid;
            await load();
            // My own role may have changed what I can see.
            _session.loadMe();
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
  }

  Future<void> delete(Role role) async {
    await _accessRepository.deleteRole(role.uuid).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        showSuccessSnack("Role deleted".tr);
        selected.value = null;
        load();
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
