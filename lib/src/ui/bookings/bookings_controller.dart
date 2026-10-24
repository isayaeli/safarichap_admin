import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/booking/booking.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/booking_repository.dart';

class BookingsController extends PagedController<AdminBooking> {
  final BookingRepository _bookingRepository;
  BookingsController(this._bookingRepository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<AdminBooking>>> fetch(Map<String, dynamic> query) =>
      _bookingRepository.retrieveBookings(query);
}

class BookingDetailController extends GetxController {
  final BookingRepository _bookingRepository;
  final String uuid;
  BookingDetailController(this._bookingRepository, this.uuid);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isNotifying = false.obs;
  final booking = Rxn<AdminBooking>();

  @override
  void onInit() {
    getBooking();
    super.onInit();
  }

  Future<void> getBooking() async {
    await _bookingRepository.retrieveBooking(uuid).execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        booking.value = result.data as AdminBooking;
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<void> updateStatus(BookingStatus status) async {
    await _bookingRepository.updateStatus(uuid, status.wire).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        booking.value = result.data as AdminBooking;
        showSuccessSnack(
          "Booking is @status".trParams({'status': status.label}),
        );
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<bool> saveDocument({
    String? documentUuid,
    required Map<String, dynamic> body,
  }) async {
    var ok = false;
    await _bookingRepository
        .saveDocument(bookingUuid: uuid, documentUuid: documentUuid, body: body)
        .execute((result) {
          isSaving.value = result is Loading;
          if (result is Success) {
            ok = true;
            showSuccessSnack("Document saved".tr);
            getBooking();
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
    return ok;
  }

  Future<void> deleteDocument(TripDocument doc) async {
    await _bookingRepository.deleteDocument(doc.uuid).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        showSuccessSnack("Document removed".tr);
        getBooking();
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<void> notifyTraveller() async {
    await _bookingRepository.notifyTraveller(uuid).execute((result) {
      isNotifying.value = result is Loading;
      if (result is Success) {
        showSuccessSnack("The traveller was notified".tr);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
