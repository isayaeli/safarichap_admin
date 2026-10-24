// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'payments_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$PaymentsService extends PaymentsService {
  _$PaymentsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = PaymentsService;

  @override
  Future<Response<dynamic>> getPayments(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/payments/');
    final Map<String, dynamic> $params = query;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPayment(String uuid) {
    final Uri $url = Uri.parse('/api/admin/payments/${uuid}/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> reconcilePayment(String uuid) {
    final Uri $url = Uri.parse('/api/admin/payments/${uuid}/reconcile/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getRefunds(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/refunds/');
    final Map<String, dynamic> $params = query;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> processRefund(String uuid) {
    final Uri $url = Uri.parse('/api/admin/refunds/${uuid}/process/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> markRefundCompleted(
    String uuid,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/refunds/${uuid}/mark-completed/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
