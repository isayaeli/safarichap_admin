import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';

/// Loads the trip being edited plus the operator and destination pickers.
class ItineraryFormController extends GetxController {
  final CatalogueRepository _catalogueRepository;
  final String? uuid;
  ItineraryFormController(this._catalogueRepository, this.uuid);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final itinerary = Rxn<ItineraryDetail>();
  final operators = <Operator>[].obs;
  final destinations = <Destination>[].obs;

  bool get isNew => uuid == null;

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    isLoading.value = true;
    final results = await Future.wait([
      _catalogueRepository.retrieveAll(
        CatalogueRepository.operators,
        Operator.fromJson,
      ),
      _catalogueRepository.retrieveAll(
        CatalogueRepository.destinations,
        Destination.fromJson,
      ),
      if (uuid != null) _catalogueRepository.retrieveItinerary(uuid!),
    ]);
    for (final r in results) {
      if (r is Fail) showErrorSnack((r as Fail).message);
    }
    if (results[0] is Success) {
      operators.assignAll((results[0] as Success).data as List<Operator>);
    }
    if (results[1] is Success) {
      destinations.assignAll((results[1] as Success).data as List<Destination>);
    }
    if (results.length > 2 && results[2] is Success) {
      itinerary.value = (results[2] as Success).data as ItineraryDetail;
    }
    isLoading.value = false;
  }

  /// Returns true when saved; [body] is the full writable trip.
  Future<bool> save(Map<String, dynamic> body) async {
    var ok = false;
    await _catalogueRepository
        .save(
          CatalogueRepository.itineraries,
          uuid: uuid ?? itinerary.value?.uuid,
          body: body,
          fromJson: ItineraryDetail.fromJson,
        )
        .execute((result) {
          isSaving.value = result is Loading;
          if (result is Success) {
            ok = true;
            itinerary.value = result.data as ItineraryDetail;
            showSuccessSnack("Trip saved".tr);
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
    return ok;
  }

  Future<bool> delete() async {
    final id = uuid ?? itinerary.value?.uuid;
    if (id == null) return false;
    var ok = false;
    await _catalogueRepository
        .delete(CatalogueRepository.itineraries, id)
        .execute((result) {
          isDeleting.value = result is Loading;
          if (result is Success) {
            ok = true;
            showSuccessSnack("Trip deleted".tr);
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
    return ok;
  }
}
