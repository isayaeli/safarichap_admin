import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/payment/payment.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/payment_repository.dart';

class PaymentsController extends PagedController<AdminPayment> {
  final PaymentRepository _paymentRepository;
  PaymentsController(this._paymentRepository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<AdminPayment>>> fetch(Map<String, dynamic> query) =>
      _paymentRepository.retrievePayments(query);
}

class PaymentDetailController extends GetxController {
  final PaymentRepository _paymentRepository;
  final String uuid;
  PaymentDetailController(this._paymentRepository, this.uuid);

  final isLoading = false.obs;
  final isReconciling = false.obs;
  final payment = Rxn<AdminPayment>();

  @override
  void onInit() {
    getPayment();
    super.onInit();
  }

  Future<void> getPayment() async {
    await _paymentRepository.retrievePayment(uuid).execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        payment.value = result.data as AdminPayment;
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<void> reconcile() async {
    await _paymentRepository.reconcilePayment(uuid).execute((result) {
      isReconciling.value = result is Loading;
      if (result is Success) {
        final updated = result.data as AdminPayment;
        payment.value = updated;
        if (updated.status == PaymentStatus.pending) {
          showInfosSnack("The provider hasn't confirmed this payment yet.".tr);
        } else {
          showSuccessSnack(
            "Payment is now @status".trParams({'status': updated.status.label}),
          );
        }
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
