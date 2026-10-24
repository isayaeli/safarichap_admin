import 'package:chopper/chopper.dart';

part 'customers_service.chopper.dart';

@ChopperApi(baseUrl: "/api/admin")
abstract class CustomersService extends ChopperService {
  @GET(path: "/users/")
  Future<Response> getUsers(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/users/{uuid}/")
  Future<Response> getUser(@Path("uuid") String uuid);

  @PATCH(path: "/users/{uuid}/")
  Future<Response> updateUser(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  /// CSV body; read `response.base.body`.
  @GET(path: "/users/export/")
  Future<Response> exportUsers(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/kyc/")
  Future<Response> getKyc(@QueryMap() Map<String, dynamic> query);

  @POST(path: "/kyc/{uuid}/approve/")
  Future<Response> approveKyc(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @POST(path: "/kyc/{uuid}/reject/")
  Future<Response> rejectKyc(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  static CustomersService create([ChopperClient? client]) {
    return _$CustomersService(client);
  }
}
