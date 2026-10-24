import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/payment/payment.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/payment_repository.dart';

class RefundsController extends PagedController<AdminRefund> {
  final PaymentRepository _paymentRepository;
  RefundsController(this._paymentRepository);

  final working = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<AdminRefund>>> fetch(Map<String, dynamic> query) =>
      _paymentRepository.retrieveRefunds(query);

  Future<void> process(AdminRefund refund) async {
    await _paymentRepository
        .processRefund(refund.uuid)
        .execute((result) => _onResult(refund, result));
  }

  Future<void> markCompleted(AdminRefund refund, String reference) async {
    await _paymentRepository
        .markRefundCompleted(refund.uuid, reference)
        .execute((result) => _onResult(refund, result));
  }

  void _onResult(AdminRefund refund, Result result) {
    working.value = result is Loading ? refund.uuid : null;
    if (result is Success) {
      final updated = result.data as AdminRefund;
      replaceWhere((r) => r.uuid == refund.uuid, updated);
      if (updated.status == RefundStatus.failed) {
        showErrorSnack(
          updated.failure_reason ?? "The provider rejected the refund.".tr,
        );
      } else {
        showSuccessSnack(
          "Refund is @status".trParams({'status': updated.status.label}),
        );
      }
    } else if (result is Fail) {
      showErrorSnack(result.message);
    }
  }
}
