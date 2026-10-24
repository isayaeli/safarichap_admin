import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import '../models/result.dart';

class GoalRepository {
  final AdminClient _client;
  GoalRepository(this._client);

  Future<Result<Paginated<GoalSummary>>> retrieveGoals(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.goalsService().getGoals(cleanQuery(query));
    return response.toResult(
      (body) => Paginated.fromJson(body, GoalSummary.fromJson),
    );
  }

  Future<Result<GoalDetail>> retrieveGoal(String uuid) async {
    final response = await _client.goalsService().getGoal(uuid);
    return response.toResult(
      (body) => GoalDetail.fromJson(body as Map<String, dynamic>),
    );
  }

  /// [action] is pause | resume | reschedule | cancel; the API applies the
  /// same rules as the app (price stays locked, refunds per policy).
  Future<Result<GoalDetail>> goalAction(
    String uuid,
    String action,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.goalsService().goalAction(
      uuid,
      action,
      body,
    );
    return response.toResult(
      (body) => GoalDetail.fromJson(body as Map<String, dynamic>),
    );
  }
}
