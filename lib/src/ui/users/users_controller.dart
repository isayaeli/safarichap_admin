import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/file_download.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import 'package:safarichap_admin/src/data/repositories/customer_repository.dart';

class UsersController extends PagedController<AdminUser> {
  final CustomerRepository _customerRepository;
  UsersController(this._customerRepository);

  final isExporting = false.obs;

  @override
  Map<String, dynamic> get initialFilters => {'is_staff': 'false'};

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<AdminUser>>> fetch(Map<String, dynamic> query) =>
      _customerRepository.retrieveUsers(query);

  Future<void> exportCsv() async {
    final query = Map<String, dynamic>.from(this.query)
      ..remove('page')
      ..remove('page_size');
    await _customerRepository.exportUsers(query).execute((result) {
      isExporting.value = result is Loading;
      if (result is Success) {
        downloadTextFile('safarichap-customers.csv', result.data as String);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}

class UserDetailController extends GetxController {
  final CustomerRepository _customerRepository;
  final String uuid;
  UserDetailController(this._customerRepository, this.uuid);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final user = Rxn<AdminUser>();

  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  Future<void> getUser() async {
    await _customerRepository.retrieveUser(uuid).execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        user.value = result.data as AdminUser;
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<bool> updateUser(
    Map<String, dynamic> body, {
    String? successMessage,
  }) async {
    var ok = false;
    await _customerRepository.updateUser(uuid, body).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        ok = true;
        showSuccessSnack(successMessage ?? "Saved".tr);
        getUser();
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
    return ok;
  }
}
