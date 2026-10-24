import 'package:safarichap_admin/src/core/utils/paged_controller.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';

class AuditController extends PagedController<AuditLogEntry> {
  final AccessRepository _accessRepository;
  AuditController(this._accessRepository);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  Future<Result<Paginated<AuditLogEntry>>> fetch(Map<String, dynamic> query) =>
      _accessRepository.retrieveAuditLogs(query);
}
