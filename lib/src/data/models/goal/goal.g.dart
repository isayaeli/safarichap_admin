// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalSummary _$GoalSummaryFromJson(Map<String, dynamic> json) => GoalSummary(
  uuid: json['uuid'] as String,
  title: json['title'] as String,
  user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
  itinerary_uuid: json['itinerary_uuid'] as String,
  itinerary_title: json['itinerary_title'] as String,
  travel_date: DateTime.parse(json['travel_date'] as String),
  pay_by_date: DateTime.parse(json['pay_by_date'] as String),
  currency: json['currency'] as String,
  total_amount: (json['total_amount'] as num).toInt(),
  deposit_amount: (json['deposit_amount'] as num).toInt(),
  amount_paid: (json['amount_paid'] as num).toInt(),
  frequency: $enumDecode(_$PaymentFrequencyEnumMap, json['frequency']),
  status: $enumDecode(_$GoalStatusEnumMap, json['status']),
  consecutive_missed: (json['consecutive_missed'] as num).toInt(),
  created_at: DateTime.parse(json['created_at'] as String),
  activated_at: json['activated_at'] == null
      ? null
      : DateTime.parse(json['activated_at'] as String),
  completed_at: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
);

Map<String, dynamic> _$GoalSummaryToJson(GoalSummary instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'title': instance.title,
      'user': instance.user.toJson(),
      'itinerary_uuid': instance.itinerary_uuid,
      'itinerary_title': instance.itinerary_title,
      'travel_date': instance.travel_date.toIso8601String(),
      'pay_by_date': instance.pay_by_date.toIso8601String(),
      'currency': instance.currency,
      'total_amount': instance.total_amount,
      'deposit_amount': instance.deposit_amount,
      'amount_paid': instance.amount_paid,
      'frequency': _$PaymentFrequencyEnumMap[instance.frequency]!,
      'status': _$GoalStatusEnumMap[instance.status]!,
      'consecutive_missed': instance.consecutive_missed,
      'created_at': instance.created_at.toIso8601String(),
      'activated_at': instance.activated_at?.toIso8601String(),
      'completed_at': instance.completed_at?.toIso8601String(),
    };

const _$PaymentFrequencyEnumMap = {
  PaymentFrequency.weekly: 'weekly',
  PaymentFrequency.biWeekly: 'bi_weekly',
  PaymentFrequency.monthly: 'monthly',
  PaymentFrequency.custom: 'custom',
};

const _$GoalStatusEnumMap = {
  GoalStatus.draft: 'draft',
  GoalStatus.active: 'active',
  GoalStatus.paused: 'paused',
  GoalStatus.completed: 'completed',
  GoalStatus.cancelled: 'cancelled',
  GoalStatus.expired: 'expired',
};

Traveller _$TravellerFromJson(Map<String, dynamic> json) => Traveller(
  name: json['name'] as String,
  age_category: $enumDecode(_$AgeCategoryEnumMap, json['age_category']),
  residency: $enumDecode(_$ResidencyEnumMap, json['residency']),
);

Map<String, dynamic> _$TravellerToJson(Traveller instance) => <String, dynamic>{
  'name': instance.name,
  'age_category': _$AgeCategoryEnumMap[instance.age_category]!,
  'residency': _$ResidencyEnumMap[instance.residency]!,
};

const _$AgeCategoryEnumMap = {
  AgeCategory.adult: 'adult',
  AgeCategory.child: 'child',
};

const _$ResidencyEnumMap = {
  Residency.resident: 'resident',
  Residency.nonResident: 'non_resident',
};

Installment _$InstallmentFromJson(Map<String, dynamic> json) => Installment(
  uuid: json['uuid'] as String,
  due_date: DateTime.parse(json['due_date'] as String),
  amount: (json['amount'] as num).toInt(),
  amount_paid: (json['amount_paid'] as num).toInt(),
  status: $enumDecode(_$InstallmentStatusEnumMap, json['status']),
  is_deposit: json['is_deposit'] as bool,
);

Map<String, dynamic> _$InstallmentToJson(Installment instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'due_date': instance.due_date.toIso8601String(),
      'amount': instance.amount,
      'amount_paid': instance.amount_paid,
      'status': _$InstallmentStatusEnumMap[instance.status]!,
      'is_deposit': instance.is_deposit,
    };

const _$InstallmentStatusEnumMap = {
  InstallmentStatus.upcoming: 'upcoming',
  InstallmentStatus.paid: 'paid',
  InstallmentStatus.partiallyPaid: 'partially_paid',
  InstallmentStatus.missed: 'missed',
};

CancellationQuote _$CancellationQuoteFromJson(Map<String, dynamic> json) =>
    CancellationQuote(
      currency: json['currency'] as String,
      amount_paid: (json['amount_paid'] as num).toInt(),
      refund_percentage: (json['refund_percentage'] as num).toInt(),
      processing_fee: (json['processing_fee'] as num).toInt(),
      refund_amount: (json['refund_amount'] as num).toInt(),
      policy: json['policy'] as String,
    );

Map<String, dynamic> _$CancellationQuoteToJson(CancellationQuote instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'amount_paid': instance.amount_paid,
      'refund_percentage': instance.refund_percentage,
      'processing_fee': instance.processing_fee,
      'refund_amount': instance.refund_amount,
      'policy': instance.policy,
    };

GoalDetail _$GoalDetailFromJson(Map<String, dynamic> json) => GoalDetail(
  uuid: json['uuid'] as String,
  title: json['title'] as String,
  user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
  itinerary_uuid: json['itinerary_uuid'] as String,
  itinerary_title: json['itinerary_title'] as String,
  travel_date: DateTime.parse(json['travel_date'] as String),
  pay_by_date: DateTime.parse(json['pay_by_date'] as String),
  currency: json['currency'] as String,
  total_amount: (json['total_amount'] as num).toInt(),
  deposit_amount: (json['deposit_amount'] as num).toInt(),
  amount_paid: (json['amount_paid'] as num).toInt(),
  frequency: $enumDecode(_$PaymentFrequencyEnumMap, json['frequency']),
  status: $enumDecode(_$GoalStatusEnumMap, json['status']),
  consecutive_missed: (json['consecutive_missed'] as num).toInt(),
  created_at: DateTime.parse(json['created_at'] as String),
  activated_at: json['activated_at'] == null
      ? null
      : DateTime.parse(json['activated_at'] as String),
  completed_at: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  custom_days: (json['custom_days'] as num).toInt(),
  cancellation_reason: json['cancellation_reason'] as String?,
  locked_pricing_snapshot:
      json['locked_pricing_snapshot'] as Map<String, dynamic>?,
  travellers: (json['travellers'] as List<dynamic>)
      .map((e) => Traveller.fromJson(e as Map<String, dynamic>))
      .toList(),
  installments: (json['installments'] as List<dynamic>)
      .map((e) => Installment.fromJson(e as Map<String, dynamic>))
      .toList(),
  payments: (json['payments'] as List<dynamic>)
      .map((e) => AdminPayment.fromJson(e as Map<String, dynamic>))
      .toList(),
  refunds: (json['refunds'] as List<dynamic>)
      .map((e) => AdminRefund.fromJson(e as Map<String, dynamic>))
      .toList(),
  booking_uuid: json['booking_uuid'] as String?,
  cancellation_quote: json['cancellation_quote'] == null
      ? null
      : CancellationQuote.fromJson(
          json['cancellation_quote'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GoalDetailToJson(GoalDetail instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'title': instance.title,
      'user': instance.user.toJson(),
      'itinerary_uuid': instance.itinerary_uuid,
      'itinerary_title': instance.itinerary_title,
      'travel_date': instance.travel_date.toIso8601String(),
      'pay_by_date': instance.pay_by_date.toIso8601String(),
      'currency': instance.currency,
      'total_amount': instance.total_amount,
      'deposit_amount': instance.deposit_amount,
      'amount_paid': instance.amount_paid,
      'frequency': _$PaymentFrequencyEnumMap[instance.frequency]!,
      'status': _$GoalStatusEnumMap[instance.status]!,
      'consecutive_missed': instance.consecutive_missed,
      'created_at': instance.created_at.toIso8601String(),
      'activated_at': instance.activated_at?.toIso8601String(),
      'completed_at': instance.completed_at?.toIso8601String(),
      'custom_days': instance.custom_days,
      'cancellation_reason': instance.cancellation_reason,
      'locked_pricing_snapshot': instance.locked_pricing_snapshot,
      'travellers': instance.travellers.map((e) => e.toJson()).toList(),
      'installments': instance.installments.map((e) => e.toJson()).toList(),
      'payments': instance.payments.map((e) => e.toJson()).toList(),
      'refunds': instance.refunds.map((e) => e.toJson()).toList(),
      'booking_uuid': instance.booking_uuid,
      'cancellation_quote': instance.cancellation_quote?.toJson(),
    };
