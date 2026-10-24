import 'package:chopper/chopper.dart';

part 'payments_service.chopper.dart';

@ChopperApi(baseUrl: "/api/admin")
abstract class PaymentsService extends ChopperService {
  @GET(path: "/payments/")
  Future<Response> getPayments(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/payments/{uuid}/")
  Future<Response> getPayment(@Path("uuid") String uuid);

  @POST(path: "/payments/{uuid}/reconcile/", optionalBody: true)
  Future<Response> reconcilePayment(@Path("uuid") String uuid);

  @GET(path: "/refunds/")
  Future<Response> getRefunds(@QueryMap() Map<String, dynamic> query);

  @POST(path: "/refunds/{uuid}/process/", optionalBody: true)
  Future<Response> processRefund(@Path("uuid") String uuid);

  @POST(path: "/refunds/{uuid}/mark-completed/")
  Future<Response> markRefundCompleted(
    @Path("uuid") String uuid,
    @Body() Map<String, dynamic> body,
  );

  static PaymentsService create([ChopperClient? client]) {
    return _$PaymentsService(client);
  }
}
