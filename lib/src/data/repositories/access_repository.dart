import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import '../models/result.dart';

class AccessRepository {
  final AdminClient _client;
  AccessRepository(this._client);

  Future<Result<AdminMe>> retrieveMe() async {
    final response = await _client.accessService().getMe();
    return response.toResult(
      (body) => AdminMe.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<List<AdminPermission>>> retrievePermissions() async {
    final response = await _client.accessService().getPermissions();
    return response.toResult(
      (body) => (body as List)
          .map((e) => AdminPermission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<List<Role>>> retrieveRoles() async {
    final response = await _client.accessService().getRoles();
    return response.toResult(
      (body) => (body as List)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Result<Role>> saveRole({
    String? uuid,
    required Map<String, dynamic> body,
  }) async {
    final service = _client.accessService();
    final response = uuid == null
        ? await service.createRole(body)
        : await service.updateRole(uuid, body);
    return response.toResult(
      (body) => Role.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<void>> deleteRole(String uuid) async {
    final response = await _client.accessService().deleteRole(uuid);
    return response.toResult((_) {});
  }

  Future<Result<Paginated<StaffMember>>> retrieveStaff(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.accessService().getStaff(cleanQuery(query));
    return response.toResult(
      (body) => Paginated.fromJson(body, StaffMember.fromJson),
    );
  }

  Future<Result<StaffMember>> inviteStaff({
    required String email,
    required String fullName,
    required List<String> roleUuids,
  }) async {
    final response = await _client.accessService().inviteStaff({
      'email': email,
      'full_name': fullName,
      'roles': roleUuids,
    });
    return response.toResult(
      (body) => StaffMember.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<StaffMember>> updateStaff(
    String uuid,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.accessService().updateStaff(uuid, body);
    return response.toResult(
      (body) => StaffMember.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<void>> removeStaff(String uuid) async {
    final response = await _client.accessService().removeStaff(uuid);
    return response.toResult((_) {});
  }

  Future<Result<Paginated<AuditLogEntry>>> retrieveAuditLogs(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.accessService().getAuditLogs(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AuditLogEntry.fromJson),
    );
  }
}
