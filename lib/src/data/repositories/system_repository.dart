import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/stats/stats.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import '../models/result.dart';

class SystemRepository {
  final AdminClient _client;
  SystemRepository(this._client);

  Future<Result<AdminStats>> retrieveStats({int days = 30}) async {
    final response = await _client.systemService().getStats(days);
    return response.toResult(
      (body) => AdminStats.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<List<AdminFxRate>>> retrieveCurrentFxRates() async {
    final response = await _client.systemService().getCurrentFxRates();
    return response.toResult(
      (body) => (body as List)
          .map((e) => AdminFxRate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<Paginated<AdminFxRate>>> retrieveFxHistory(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.systemService().getFxRates(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AdminFxRate.fromJson),
    );
  }

  Future<Result<AdminFxRate>> overrideFxRate(
    String currency,
    int numerator,
    int denominator,
  ) async {
    final response = await _client.systemService().overrideFxRate({
      'from_currency': currency,
      'numerator': numerator,
      'denominator': denominator,
    });
    return response.toResult(
      (body) => AdminFxRate.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<void>> refreshFxRates() async {
    final response = await _client.systemService().refreshFxRates();
    return response.toResult((_) {});
  }

  Future<Result<AppSettings>> retrieveSettings() async {
    final response = await _client.systemService().getSettings();
    return response.toResult(
      (body) => AppSettings.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<AppSettings>> updateSettings(Map<String, dynamic> body) async {
    final response = await _client.systemService().updateSettings(body);
    return response.toResult(
      (body) => AppSettings.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<Paginated<AdminNotification>>> retrieveNotifications(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.systemService().getNotifications(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AdminNotification.fromJson),
    );
  }

  Future<Result<Paginated<Broadcast>>> retrieveBroadcasts(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.systemService().getBroadcasts(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, Broadcast.fromJson),
    );
  }

  /// With `dry_run: true` the body is `{"recipients": n}`.
  Future<Result<int>> sendBroadcast(Map<String, dynamic> body) async {
    final response = await _client.systemService().sendBroadcast(body);
    return response.toResult(
      (body) => ((body as Map<String, dynamic>)['recipients'] as num).toInt(),
    );
  }
}
