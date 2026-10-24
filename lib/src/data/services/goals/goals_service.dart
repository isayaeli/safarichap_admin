import 'package:chopper/chopper.dart';

part 'goals_service.chopper.dart';

@ChopperApi(baseUrl: "/api/admin/goals")
abstract class GoalsService extends ChopperService {
  @GET(path: "/")
  Future<Response> getGoals(@QueryMap() Map<String, dynamic> query);

  @GET(path: "/{uuid}/")
  Future<Response> getGoal(@Path("uuid") String uuid);

  /// [action] is pause | resume | reschedule | cancel.
  @POST(path: "/{uuid}/{action}/")
  Future<Response> goalAction(
    @Path("uuid") String uuid,
    @Path("action") String action,
    @Body() Map<String, dynamic> body,
  );

  static GoalsService create([ChopperClient? client]) {
    return _$GoalsService(client);
  }
}
