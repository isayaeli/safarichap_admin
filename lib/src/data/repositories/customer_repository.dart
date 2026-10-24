import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';
import '../models/result.dart';

class CustomerRepository {
  final AdminClient _client;
  CustomerRepository(this._client);

  Future<Result<Paginated<AdminUser>>> retrieveUsers(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.customersService().getUsers(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AdminUser.fromJson),
    );
  }

  Future<Result<AdminUser>> retrieveUser(String uuid) async {
    final response = await _client.customersService().getUser(uuid);
    return response.toResult(
      (body) => AdminUser.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<AdminUser>> updateUser(
    String uuid,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.customersService().updateUser(uuid, body);
    return response.toResult(
      (body) => AdminUser.fromJson(body as Map<String, dynamic>),
    );
  }

  /// CSV text of every user matching [query].
  Future<Result<String>> exportUsers(Map<String, dynamic> query) async {
    final response = await _client.customersService().exportUsers(
      cleanQuery(query),
    );
    return response.toResult((_) => response.bodyString);
  }

  Future<Result<Paginated<KycDocument>>> retrieveKyc(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.customersService().getKyc(cleanQuery(query));
    return response.toResult(
      (body) => Paginated.fromJson(body, KycDocument.fromJson),
    );
  }

  Future<Result<KycDocument>> reviewKyc(
    String uuid, {
    required bool approve,
    String note = '',
  }) async {
    final service = _client.customersService();
    final body = {'note': note};
    final response = approve
        ? await service.approveKyc(uuid, body)
        : await service.rejectKyc(uuid, body);
    return response.toResult(
      (body) => KycDocument.fromJson(body as Map<String, dynamic>),
    );
  }
}
