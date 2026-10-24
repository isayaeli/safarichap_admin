import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';

/// List + create/update/delete for one catalogue resource (operators,
/// destinations, refund-policies, itineraries). Registered with the resource as tag.
class CatalogueController<T> extends PagedController<T> {
  final CatalogueRepository _catalogueRepository;
  final String resource;
  final T Function(Map<String, dynamic>) fromJson;
  CatalogueController(this._catalogueRepository, this.resource, this.fromJson);

  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<T>>> fetch(Map<String, dynamic> query) =>
      _catalogueRepository.retrieveList(resource, query, fromJson);

  Future<bool> save({String? uuid, required Map<String, dynamic> body}) async {
    var ok = false;
    await _catalogueRepository
        .save(resource, uuid: uuid, body: body, fromJson: fromJson)
        .execute((result) {
          isSaving.value = result is Loading;
          if (result is Success) {
            ok = true;
            showSuccessSnack("Saved".tr);
            load();
          } else if (result is Fail) {
            showErrorSnack(result.message);
          }
        });
    return ok;
  }

  Future<void> delete(String uuid) async {
    await _catalogueRepository.delete(resource, uuid).execute((result) {
      isSaving.value = result is Loading;
      if (result is Success) {
        showSuccessSnack("Deleted".tr);
        load();
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
