import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';

class StaffController extends PagedController<StaffMember> {
  final AccessRepository _accessRepository;
  StaffController(this._accessRepository);

  final roles = <Role>[].obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    _accessRepository.retrieveRoles().execute((result) {
      if (result is Success) roles.assignAll(result.data as List<Role>);
    });
  }

  @override
  Future<Result<Paginated<StaffMember>>> fetch(Map<String, dynamic> query) =>
      _accessRepository.retrieveStaff(query);

  /// Returns the password-setup link (also emailed) or null on failure.
  Future<String?> invite({
    required String email,
    required String fullName,
    required List<String> roleUuids,
  }) async {
    String? link;
    var ok = false;
    await _accessRepository
        .inviteStaff(email: email, fullName: fullName, roleUuids: roleUuids)
        .execute((result) {
          isSaving.value = result is Loading;
          if (result is Success) {
            ok = true;
            link = (result.data as StaffMember).password_link;
            load();
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
    return ok ? (link ?? '') : null;
  }

  Future<bool> updateStaff(
    StaffMember member,
    Map<String, dynamic> body, {
    String? message,
  }) async {
    var ok = false;
    await _accessRepository.updateStaff(member.uuid, body).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        ok = true;
        replaceWhere((m) => m.uuid == member.uuid, result.data as StaffMember);
        showSuccessSnack(message ?? "Saved".tr);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
    return ok;
  }

  Future<void> remove(StaffMember member) async {
    await _accessRepository.removeStaff(member.uuid).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        showSuccessSnack("Access removed".tr);
        load();
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showInfosSnack("Copied".tr);
  }
}
