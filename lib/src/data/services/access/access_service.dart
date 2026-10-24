import 'package:chopper/chopper.dart';

part 'access_service.chopper.dart';

/// Signed-in staff profile, roles, staff and the audit log.
@ChopperApi(baseUrl: "/api/admin")
abstract class AccessService extends ChopperService {
  @GET(path: "/me/")
  Future<Response> getMe();

  @GET(path: "/permissions/")
  Future<Response> getPermissions();

  @GET(path: "/roles/")
  Future<Response> getRoles();

  @POST(path: "/roles/")
  Future<Response> createRole(@Body() Map<String, dynamic> body);

  @PATCH(path: "/roles/{uuid}/")
  Future<Response> updateRole(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: "/roles/{uuid}/")
  Future<Response> deleteRole(@Path("uuid") String uuid);

  @GET(path: "/staff/")
  Future<Response> getStaff(@QueryMap() Map<String, dynamic> query);

  @POST(path: "/staff/")
  Future<Response> inviteStaff(@Body() Map<String, dynamic> body);

  @PATCH(path: "/staff/{uuid}/")
  Future<Response> updateStaff(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: "/staff/{uuid}/")
  Future<Response> removeStaff(@Path("uuid") String uuid);

  @GET(path: "/audit-logs/")
  Future<Response> getAuditLogs(@QueryMap() Map<String, dynamic> query);

  static AccessService create([ChopperClient? client]) {
    return _$AccessService(client);
  }
}
