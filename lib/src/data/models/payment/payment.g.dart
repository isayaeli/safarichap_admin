// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminPayment _$AdminPaymentFromJson(Map<String, dynamic> json) => AdminPayment(
  uuid: json['uuid'] as String,
  user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
  goal_uuid: json['goal_uuid'] as String,
  goal_title: json['goal_title'] as String,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String,
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  phone_number: json['phone_number'] as String?,
  order_reference: json['order_reference'] as String,
  provider: json['provider'] as String,
  provider_reference: json['provider_reference'] as String?,
  provider_txn_id: json['provider_txn_id'] as String?,
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  failure_reason: json['failure_reason'] as String?,
  receipt_number: json['receipt_number'] as String?,
  settled_at: json['settled_at'] == null
      ? null
      : DateTime.parse(json['settled_at'] as String),
  created_at: DateTime.parse(json['created_at'] as String),
  raw_webhook: json['raw_webhook'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AdminPaymentToJson(AdminPayment instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'user': instance.user.toJson(),
      'goal_uuid': instance.goal_uuid,
      'goal_title': instance.goal_title,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'phone_number': instance.phone_number,
      'order_reference': instance.order_reference,
      'provider': instance.provider,
      'provider_reference': instance.provider_reference,
      'provider_txn_id': instance.provider_txn_id,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'failure_reason': instance.failure_reason,
      'receipt_number': instance.receipt_number,
      'settled_at': instance.settled_at?.toIso8601String(),
      'created_at': instance.created_at.toIso8601String(),
      'raw_webhook': instance.raw_webhook,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.mpesa: 'mpesa',
  PaymentMethod.airtelMoney: 'airtel_money',
  PaymentMethod.mixxByYas: 'mixx_by_yas',
  PaymentMethod.haloPesa: 'halo_pesa',
  PaymentMethod.card: 'card',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.success: 'success',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

AdminRefund _$AdminRefundFromJson(Map<String, dynamic> json) => AdminRefund(
  uuid: json['uuid'] as String,
  user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
  goal_uuid: json['goal_uuid'] as String,
  goal_title: json['goal_title'] as String,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String,
  order_reference: json['order_reference'] as String,
  phone_number: json['phone_number'] as String?,
  status: $enumDecode(_$RefundStatusEnumMap, json['status']),
  provider_reference: json['provider_reference'] as String?,
  attempts: (json['attempts'] as num).toInt(),
  failure_reason: json['failure_reason'] as String?,
  processed_at: json['processed_at'] == null
      ? null
      : DateTime.parse(json['processed_at'] as String),
  created_at: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AdminRefundToJson(AdminRefund instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'user': instance.user.toJson(),
      'goal_uuid': instance.goal_uuid,
      'goal_title': instance.goal_title,
      'amount': instance.amount,
      'currency': instance.currency,
      'order_reference': instance.order_reference,
      'phone_number': instance.phone_number,
      'status': _$RefundStatusEnumMap[instance.status]!,
      'provider_reference': instance.provider_reference,
      'attempts': instance.attempts,
      'failure_reason': instance.failure_reason,
      'processed_at': instance.processed_at?.toIso8601String(),
      'created_at': instance.created_at.toIso8601String(),
    };

const _$RefundStatusEnumMap = {
  RefundStatus.pending: 'pending',
  RefundStatus.processing: 'processing',
  RefundStatus.completed: 'completed',
  RefundStatus.failed: 'failed',
};
