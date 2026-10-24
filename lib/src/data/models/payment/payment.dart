// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../enums.dart';
import '../user/admin_user.dart';

part 'payment.g.dart';

@JsonSerializable()
class AdminPayment {
  final String uuid;
  final UserRef user;
  final String goal_uuid;
  final String goal_title;
  final int amount;
  final String currency;
  final PaymentMethod method;
  final String? phone_number;
  final String order_reference;

  /// clickpesa | flutterwave
  final String provider;
  final String? provider_reference;
  final String? provider_txn_id;
  final PaymentStatus status;
  final String? failure_reason;
  final String? receipt_number;
  final DateTime? settled_at;
  final DateTime created_at;

  /// Detail only, and only with `payments.view_raw`.
  final Map<String, dynamic>? raw_webhook;

  AdminPayment({
    required this.uuid,
    required this.user,
    required this.goal_uuid,
    required this.goal_title,
    required this.amount,
    required this.currency,
    required this.method,
    this.phone_number,
    required this.order_reference,
    required this.provider,
    this.provider_reference,
    this.provider_txn_id,
    required this.status,
    this.failure_reason,
    this.receipt_number,
    this.settled_at,
    required this.created_at,
    this.raw_webhook,
  });

  Money get money => Money(amount, Currency.fromCode(currency));

  factory AdminPayment.fromJson(Map<String, dynamic> json) =>
      _$AdminPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$AdminPaymentToJson(this);
}

@JsonSerializable()
class AdminRefund {
  final String uuid;
  final UserRef user;
  final String goal_uuid;
  final String goal_title;
  final int amount;
  final String currency;
  final String order_reference;
  final String? phone_number;
  final RefundStatus status;
  final String? provider_reference;
  final int attempts;
  final String? failure_reason;
  final DateTime? processed_at;
  final DateTime created_at;

  AdminRefund({
    required this.uuid,
    required this.user,
    required this.goal_uuid,
    required this.goal_title,
    required this.amount,
    required this.currency,
    required this.order_reference,
    this.phone_number,
    required this.status,
    this.provider_reference,
    required this.attempts,
    this.failure_reason,
    this.processed_at,
    required this.created_at,
  });

  Money get money => Money(amount, Currency.fromCode(currency));

  factory AdminRefund.fromJson(Map<String, dynamic> json) =>
      _$AdminRefundFromJson(json);
  Map<String, dynamic> toJson() => _$AdminRefundToJson(this);
}
