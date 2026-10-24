import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/stats/stats.dart';
import 'package:safarichap_admin/src/data/repositories/system_repository.dart';

class OverviewController extends GetxController {
  final SystemRepository _systemRepository;
  OverviewController(this._systemRepository);

  final isLoading = false.obs;
  final stats = Rxn<AdminStats>();
  final days = 30.obs;

  /// The collections chart shows one currency at a time (never mixed on one axis).
  final chartCurrency = Currency.tzs.obs;

  @override
  void onInit() {
    getStats();
    super.onInit();
  }

  Future<void> getStats() async {
    await _systemRepository.retrieveStats(days: days.value).execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        stats.value = result.data as AdminStats;
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  void setDays(int value) {
    days.value = value;
    getStats();
  }
}
