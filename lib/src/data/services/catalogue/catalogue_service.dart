import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show MultipartFile;

part 'catalogue_service.chopper.dart';

/// Operators, destinations, itineraries and refund policies share one shape:
/// `/api/admin/{resource}/` with list/create and `{uuid}/` retrieve/update/delete.
@ChopperApi(baseUrl: "/api/admin")
abstract class CatalogueService extends ChopperService {
  @GET(path: "/{resource}/")
  Future<Response> listItems(
    @Path("resource") String resource,
    @QueryMap() Map<String, dynamic> query,
  );

  @GET(path: "/{resource}/{uuid}/")
  Future<Response> retrieveItem(
    @Path("resource") String resource,
    @Path("uuid") String uuid,
  );

  @POST(path: "/{resource}/")
  Future<Response> createItem(
    @Path("resource") String resource,
    @Body() Map<String, dynamic> body,
  );

  @PATCH(path: "/{resource}/{uuid}/")
  Future<Response> updateItem(
    @Path("resource") String resource,
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: "/{resource}/{uuid}/")
  Future<Response> deleteItem(
    @Path("resource") String resource,
    @Path("uuid") String uuid,
  );

  /// [folder] is itineraries | destinations | documents. Returns `{"url": ...}`.
  @POST(path: "/uploads/")
  @multipart
  Future<Response> upload(
    @Part("folder") String folder,
    @PartFile("file") MultipartFile file,
  );

  static CatalogueService create([ChopperClient? client]) {
    return _$CatalogueService(client);
  }
}
