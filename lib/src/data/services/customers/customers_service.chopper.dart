// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'customers_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CustomersService extends CustomersService {
  _$CustomersService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CustomersService;

  @override
  Future<Response<dynamic>> getUsers(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/users/');
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
  Future<Response<dynamic>> getUser(String uuid) {
    final Uri $url = Uri.parse('/api/admin/users/${uuid}/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateUser(String uuid, Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/users/${uuid}/');
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
  Future<Response<dynamic>> exportUsers(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/users/export/');
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
  Future<Response<dynamic>> getKyc(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/kyc/');
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
  Future<Response<dynamic>> approveKyc(String uuid, Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/kyc/${uuid}/approve/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> rejectKyc(String uuid, Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/kyc/${uuid}/reject/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
