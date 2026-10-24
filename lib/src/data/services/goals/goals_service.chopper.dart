// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'goals_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$GoalsService extends GoalsService {
  _$GoalsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = GoalsService;

  @override
  Future<Response<dynamic>> getGoals(Map<String, dynamic> query) {
    final Uri $url = Uri.parse('/api/admin/goals/');
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
  Future<Response<dynamic>> getGoal(String uuid) {
    final Uri $url = Uri.parse('/api/admin/goals/${uuid}/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> goalAction(
    String uuid,
    String action,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/goals/${uuid}/${action}/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}
