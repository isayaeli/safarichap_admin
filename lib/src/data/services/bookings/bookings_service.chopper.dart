// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'bookings_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$BookingsService extends BookingsService {
  _$BookingsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = BookingsService;

  @override
  Future<Response<dynamic>> getBookings(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/bookings/');
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
  Future<Response<dynamic>> getBooking(String uuid) {
    final Uri $url = Uri.parse('/api/admin/bookings/${uuid}/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateBooking(
    String uuid,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/bookings/${uuid}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addDocument(
    String uuid,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/bookings/${uuid}/documents/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> notifyTraveller(String uuid) {
    final Uri $url = Uri.parse('/api/admin/bookings/${uuid}/notify/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateDocument(
    String uuid,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/trip-documents/${uuid}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteDocument(String uuid) {
    final Uri $url = Uri.parse('/api/admin/trip-documents/${uuid}/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
