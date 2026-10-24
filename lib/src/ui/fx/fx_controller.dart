import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/data/repositories/system_repository.dart';

/// Rates in use (newest per currency) plus the full history as the table.
class FxController extends PagedController<AdminFxRate> {
  final SystemRepository _systemRepository;
  FxController(this._systemRepository);

  final current = <AdminFxRate>[].obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    ordering.value = '-fetched_at';
    refreshAll();
  }

  @override
  Future<Result<Paginated<AdminFxRate>>> fetch(Map<String, dynamic> query) =>
      _systemRepository.retrieveFxHistory(query);

  Future<void> refreshAll() async {
    load();
    await _systemRepository.retrieveCurrentFxRates().execute((result) {
      if (result is Success) {
        current.assignAll(result.data as List<AdminFxRate>);
      }
    });
  }

  Future<bool> setRate(String currency, int numerator, int denominator) async {
    var ok = false;
    await _systemRepository
        .overrideFxRate(currency, numerator, denominator)
        .execute((result) {
          isSaving.value = result is Loading;
          if (result is Success) {
            ok = true;
            showSuccessSnack("Rate saved".tr);
            refreshAll();
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
    return ok;
  }

  Future<void> fetchFromProvider() async {
    await _systemRepository.refreshFxRates().execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        showInfosSnack("Fetching rates. They appear here in a few seconds.".tr);
        Future.delayed(const Duration(seconds: 4), refreshAll);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
