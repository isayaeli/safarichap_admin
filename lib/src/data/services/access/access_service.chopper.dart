// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'access_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AccessService extends AccessService {
  _$AccessService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AccessService;

  @override
  Future<Response<dynamic>> getMe() {
    final Uri $url = Uri.parse('/api/admin/me/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPermissions() {
    final Uri $url = Uri.parse('/api/admin/permissions/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getRoles() {
    final Uri $url = Uri.parse('/api/admin/roles/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createRole(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/roles/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateRole(String uuid, Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/roles/${uuid}/');
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
  Future<Response<dynamic>> deleteRole(String uuid) {
    final Uri $url = Uri.parse('/api/admin/roles/${uuid}/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getStaff(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/staff/');
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
  Future<Response<dynamic>> inviteStaff(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/api/admin/staff/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateStaff(
    String uuid,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/staff/${uuid}/');
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
  Future<Response<dynamic>> removeStaff(String uuid) {
    final Uri $url = Uri.parse('/api/admin/staff/${uuid}/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAuditLogs(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/audit-logs/');
    final Map<String, dynamic> $params = query;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
