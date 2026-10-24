// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../enums.dart';
import '../payment/payment.dart';
import '../user/admin_user.dart';

part 'goal.g.dart';

@JsonSerializable()
class GoalSummary {
  final String uuid;
  final String title;
  final UserRef user;
  final String itinerary_uuid;
  final String itinerary_title;
  final DateTime travel_date;
  final DateTime pay_by_date;
  final String currency;
  final int total_amount;
  final int deposit_amount;
  final int amount_paid;
  final PaymentFrequency frequency;
  final GoalStatus status;
  final int consecutive_missed;
  final DateTime created_at;
  final DateTime? activated_at;
  final DateTime? completed_at;

  GoalSummary({
    required this.uuid,
    required this.title,
    required this.user,
    required this.itinerary_uuid,
    required this.itinerary_title,
    required this.travel_date,
    required this.pay_by_date,
    required this.currency,
    required this.total_amount,
    required this.deposit_amount,
    required this.amount_paid,
    required this.frequency,
    required this.status,
    required this.consecutive_missed,
    required this.created_at,
    this.activated_at,
    this.completed_at,
  });

  Currency get money => Currency.fromCode(currency);
  Money get total => Money(total_amount, money);
  Money get paid => Money(amount_paid, money);
  Money get remaining => Money(total_amount - amount_paid, money);
  double get progress =>
      total_amount == 0 ? 0 : (amount_paid / total_amount).clamp(0, 1);

  factory GoalSummary.fromJson(Map<String, dynamic> json) =>
      _$GoalSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$GoalSummaryToJson(this);
}

@JsonSerializable()
class Traveller {
  final String name;
  final AgeCategory age_category;
  final Residency residency;

  Traveller({
    required this.name,
    required this.age_category,
    required this.residency,
  });

  factory Traveller.fromJson(Map<String, dynamic> json) =>
      _$TravellerFromJson(json);
  Map<String, dynamic> toJson() => _$TravellerToJson(this);
}

@JsonSerializable()
class Installment {
  final String uuid;
  final DateTime due_date;
  final int amount;
  final int amount_paid;
  final InstallmentStatus status;
  final bool is_deposit;

  Installment({
    required this.uuid,
    required this.due_date,
    required this.amount,
    required this.amount_paid,
    required this.status,
    required this.is_deposit,
  });

  factory Installment.fromJson(Map<String, dynamic> json) =>
      _$InstallmentFromJson(json);
  Map<String, dynamic> toJson() => _$InstallmentToJson(this);
}

@JsonSerializable()
class CancellationQuote {
  final String currency;
  final int amount_paid;
  final int refund_percentage;
  final int processing_fee;
  final int refund_amount;
  final String policy;

  CancellationQuote({
    required this.currency,
    required this.amount_paid,
    required this.refund_percentage,
    required this.processing_fee,
    required this.refund_amount,
    required this.policy,
  });

  Money get refund => Money(refund_amount, Currency.fromCode(currency));
  Money get fee => Money(processing_fee, Currency.fromCode(currency));

  factory CancellationQuote.fromJson(Map<String, dynamic> json) =>
      _$CancellationQuoteFromJson(json);
  Map<String, dynamic> toJson() => _$CancellationQuoteToJson(this);
}

@JsonSerializable()
class GoalDetail extends GoalSummary {
  final int custom_days;
  final String? cancellation_reason;
  final Map<String, dynamic>? locked_pricing_snapshot;
  final List<Traveller> travellers;
  final List<Installment> installments;
  final List<AdminPayment> payments;
  final List<AdminRefund> refunds;
  final String? booking_uuid;
  final CancellationQuote? cancellation_quote;

  GoalDetail({
    required super.uuid,
    required super.title,
    required super.user,
    required super.itinerary_uuid,
    required super.itinerary_title,
    required super.travel_date,
    required super.pay_by_date,
    required super.currency,
    required super.total_amount,
    required super.deposit_amount,
    required super.amount_paid,
    required super.frequency,
    required super.status,
    required super.consecutive_missed,
    required super.created_at,
    super.activated_at,
    super.completed_at,
    required this.custom_days,
    this.cancellation_reason,
    this.locked_pricing_snapshot,
    required this.travellers,
    required this.installments,
    required this.payments,
    required this.refunds,
    this.booking_uuid,
    this.cancellation_quote,
  });

  factory GoalDetail.fromJson(Map<String, dynamic> json) =>
      _$GoalDetailFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GoalDetailToJson(this);
}
