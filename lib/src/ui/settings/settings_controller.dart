import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/data/repositories/system_repository.dart';

class SettingsController extends GetxController {
  final SystemRepository _systemRepository;
  SettingsController(this._systemRepository);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final settings = Rxn<AppSettings>();

  @override
  void onInit() {
    getSettings();
    super.onInit();
  }

  Future<void> getSettings() async {
    await _systemRepository.retrieveSettings().execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        settings.value = result.data as AppSettings;
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<void> save(Map<String, dynamic> body) async {
    await _systemRepository.updateSettings(body).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        settings.value = result.data as AppSettings;
        showSuccessSnack("Settings saved".tr);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
