import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/data/repositories/system_repository.dart';

class BroadcastsController extends PagedController<Broadcast> {
  final SystemRepository _systemRepository;
  BroadcastsController(this._systemRepository);

  final isSending = false.obs;
  final recipients = RxnInt();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<Broadcast>>> fetch(Map<String, dynamic> query) =>
      _systemRepository.retrieveBroadcasts(query);

  /// Counts recipients without sending.
  Future<void> preview(Map<String, dynamic> body) async {
    await _systemRepository.sendBroadcast({...body, 'dry_run': true}).execute((
      result,
    ) {
      if (result is Success) {
        recipients.value = result.data as int;
      } else if (result is Fail) {
        recipients.value = null;
        showErrorSnack(result.message);
      }
    });
  }

  Future<bool> send(Map<String, dynamic> body) async {
    var ok = false;
    await _systemRepository.sendBroadcast(body).execute((result) {
      isSending.value = result is Loading;
      if (result is Success) {
        ok = true;
        showSuccessSnack(
          "Sending to @n customers".trParams({'n': '${result.data}'}),
        );
        load(toPage: 1);
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
    return ok;
  }
}

class SentNotificationsController extends PagedController<AdminNotification> {
  final SystemRepository _systemRepository;
  SentNotificationsController(this._systemRepository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<AdminNotification>>> fetch(
    Map<String, dynamic> query,
  ) => _systemRepository.retrieveNotifications(query);
}
