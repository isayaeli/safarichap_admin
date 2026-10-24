import 'package:chopper/chopper.dart';

part 'system_service.chopper.dart';

@ChopperApi(baseUrl: "/api/admin")
abstract class SystemService extends ChopperService {
  @GET(path: "/stats/")
  Future<Response> getStats(@Query("days") int days);

  @GET(path: "/fx-rates/")
  Future<Response> getFxRates(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/fx-rates/current/")
  Future<Response> getCurrentFxRates();

  @POST(path: "/fx-rates/")
  Future<Response> overrideFxRate(@Body() Map<String, dynamic> body);

  @POST(path: "/fx-rates/refresh/", optionalBody: true)
  Future<Response> refreshFxRates();

  @GET(path: "/settings/")
  Future<Response> getSettings();

  @PATCH(path: "/settings/")
  Future<Response> updateSettings(@Body() Map<String, dynamic> body);

  @GET(path: "/notifications/")
  Future<Response> getNotifications(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/broadcasts/")
  Future<Response> getBroadcasts(@QueryMap() Map<String, dynamic> query);

  @POST(path: "/broadcasts/")
  Future<Response> sendBroadcast(@Body() Map<String, dynamic> body);

  static SystemService create([ChopperClient? client]) {
    return _$SystemService(client);
  }
}
