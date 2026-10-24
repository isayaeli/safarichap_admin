import 'package:chopper/chopper.dart';

part 'bookings_service.chopper.dart';

@ChopperApi(baseUrl: "/api/admin")
abstract class BookingsService extends ChopperService {
  @GET(path: "/bookings/")
  Future<Response> getBookings(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/bookings/{uuid}/")
  Future<Response> getBooking(@Path("uuid") String uuid);

  @PATCH(path: "/bookings/{uuid}/")
  Future<Response> updateBooking(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @POST(path: "/bookings/{uuid}/documents/")
  Future<Response> addDocument(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @POST(path: "/bookings/{uuid}/notify/", optionalBody: true)
  Future<Response> notifyTraveller(@Path("uuid") String uuid);

  @PATCH(path: "/trip-documents/{uuid}/")
  Future<Response> updateDocument(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: "/trip-documents/{uuid}/")
  Future<Response> deleteDocument(@Path("uuid") String uuid);

  static BookingsService create([ChopperClient? client]) {
    return _$BookingsService(client);
  }
}
