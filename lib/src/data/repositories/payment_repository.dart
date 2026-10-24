import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/payment/payment.dart';
import '../models/result.dart';

class PaymentRepository {
  final AdminClient _client;
  PaymentRepository(this._client);

  Future<Result<Paginated<AdminPayment>>> retrievePayments(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.paymentsService().getPayments(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AdminPayment.fromJson),
    );
  }

  Future<Result<AdminPayment>> retrievePayment(String uuid) async {
    final response = await _client.paymentsService().getPayment(uuid);
    return response.toResult(
      (body) => AdminPayment.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<AdminPayment>> reconcilePayment(String uuid) async {
    final response = await _client.paymentsService().reconcilePayment(uuid);
    return response.toResult(
      (body) => AdminPayment.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<Paginated<AdminRefund>>> retrieveRefunds(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.paymentsService().getRefunds(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AdminRefund.fromJson),
    );
  }

  Future<Result<AdminRefund>> processRefund(String uuid) async {
    final response = await _client.paymentsService().processRefund(uuid);
    return response.toResult(
      (body) => AdminRefund.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<AdminRefund>> markRefundCompleted(
    String uuid,
    String providerReference,
  ) async {
    final response = await _client.paymentsService().markRefundCompleted(uuid, {
      'provider_reference': providerReference,
    });
    return response.toResult(
      (body) => AdminRefund.fromJson(body as Map<String, dynamic>),
    );
  }
}
