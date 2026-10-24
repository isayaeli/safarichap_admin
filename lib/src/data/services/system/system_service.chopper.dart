// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'system_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$SystemService extends SystemService {
  _$SystemService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = SystemService;

  @override
  Future<Response<dynamic>> getStats(int days) {
    final Uri $url = Uri.parse('/api/admin/stats/');
    final Map<String, dynamic> $params = <String, dynamic>{'days': days};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getFxRates(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/fx-rates/');
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
  Future<Response<dynamic>> getCurrentFxRates() {
    final Uri $url = Uri.parse('/api/admin/fx-rates/current/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> overrideFxRate(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/fx-rates/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> refreshFxRates() {
    final Uri $url = Uri.parse('/api/admin/fx-rates/refresh/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getSettings() {
    final Uri $url = Uri.parse('/api/admin/settings/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateSettings(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/settings/');
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
  Future<Response<dynamic>> getNotifications(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/notifications/');
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
  Future<Response<dynamic>> getBroadcasts(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/broadcasts/');
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
  Future<Response<dynamic>> sendBroadcast(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/broadcasts/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
