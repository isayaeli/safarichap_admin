import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import 'package:safarichap_admin/src/data/repositories/customer_repository.dart';

class KycController extends PagedController<KycDocument> {
  final CustomerRepository _customerRepository;
  KycController(this._customerRepository);

  /// uuid of the document being approved/rejected.
  final reviewing = RxnString();

  @override
  Map<String, dynamic> get initialFilters => {'status': 'pending'};

  @override
  void onInit() {
    super.onInit();
    ordering.value = 'created_at'; // oldest first: review in submission order
    load();
  }

  @override
  Future<Result<Paginated<KycDocument>>> fetch(Map<String, dynamic> query) =>
      _customerRepository.retrieveKyc(query);

  Future<void> review(
    KycDocument doc, {
    required bool approve,
    String note = '',
  }) async {
    await _customerRepository
        .reviewKyc(doc.uuid, approve: approve, note: note)
        .execute((result) {
          reviewing.value = result is Loading ? doc.uuid : null;
          if (result is Success) {
            showSuccessSnack(
              approve ? "Identity verified".tr : "Document rejected".tr,
            );
            load();
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
  }
}
