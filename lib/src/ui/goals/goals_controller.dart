import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/goal_repository.dart';

class GoalsController extends PagedController<GoalSummary> {
  final GoalRepository _goalRepository;
  GoalsController(this._goalRepository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<GoalSummary>>> fetch(Map<String, dynamic> query) =>
      _goalRepository.retrieveGoals(query);
}

class GoalDetailController extends GetxController {
  final GoalRepository _goalRepository;
  final String uuid;
  GoalDetailController(this._goalRepository, this.uuid);

  final isLoading = false.obs;
  final isActing = false.obs;
  final goal = Rxn<GoalDetail>();

  @override
  void onInit() {
    getGoal();
    super.onInit();
  }

  Future<void> getGoal() async {
    await _goalRepository.retrieveGoal(uuid).execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        goal.value = result.data as GoalDetail;
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  /// pause | resume | reschedule | cancel
  Future<void> act(
    String action,
    Map<String, dynamic> body,
    String successMessage,
  ) async {
    await _goalRepository.goalAction(uuid, action, body).execute((result) {
      isActing.value = result is Loading;
      if (result is Success) {
        goal.value = result.data as GoalDetail;
        showSuccessSnack(successMessage);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
