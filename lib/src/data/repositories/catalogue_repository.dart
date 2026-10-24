import 'package:http/http.dart' as http;
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import '../models/result.dart';

class CatalogueRepository {
  final AdminClient _client;
  CatalogueRepository(this._client);

  static const operators = 'operators';
  static const destinations = 'destinations';
  static const itineraries = 'itineraries';
  static const refundPolicies = 'refund-policies';

  Future<Result<Paginated<T>>> retrieveList<T>(
    String resource,
    Map<String, dynamic> query,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _client.catalogueService().listItems(
      resource,
      cleanQuery(query),
    );
    return response.toResult((body) => Paginated.fromJson(body, fromJson));
  }

  /// Every item (up to 200), for pickers such as the operator dropdown.
  Future<Result<List<T>>> retrieveAll<T>(
    String resource,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final result = await retrieveList(resource, {'page_size': 200}, fromJson);
    if (result is Success<Paginated<T>>) return Success(result.data!.results);
    final fail = result as Fail<Paginated<T>>;
    return Fail(fail.message, code: fail.code);
  }

  Future<Result<ItineraryDetail>> retrieveItinerary(String uuid) async {
    final response = await _client.catalogueService().retrieveItem(
      itineraries,
      uuid,
    );
    return response.toResult(
      (body) => ItineraryDetail.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<T>> save<T>(
    String resource, {
    String? uuid,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final service = _client.catalogueService();
    final response = uuid == null
        ? await service.createItem(resource, body)
        : await service.updateItem(resource, uuid, body);
    return response.toResult((body) => fromJson(body as Map<String, dynamic>));
  }

  Future<Result<void>> delete(String resource, String uuid) async {
    final response = await _client.catalogueService().deleteItem(
      resource,
      uuid,
    );
    return response.toResult((_) {});
  }

  /// Uploads an image or PDF and returns its public URL.
  Future<Result<String>> upload({
    required String folder,
    required List<int> bytes,
    required String filename,
  }) async {
    final file = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    );
    final response = await _client.catalogueService().upload(folder, file);
    return response.toResult(
      (body) => (body as Map<String, dynamic>)['url'] as String,
    );
  }
}
