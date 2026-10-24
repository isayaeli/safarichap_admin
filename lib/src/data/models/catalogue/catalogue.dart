// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../enums.dart';

part 'catalogue.g.dart';

@JsonSerializable()
class RefundTier {
  final int min_days;
  final int percentage;

  RefundTier({required this.min_days, required this.percentage});

  factory RefundTier.fromJson(Map<String, dynamic> json) =>
      _$RefundTierFromJson(json);
  Map<String, dynamic> toJson() => _$RefundTierToJson(this);
}

@JsonSerializable()
class RefundPolicy {
  final String uuid;
  final String name;
  final List<RefundTier> tiers;

  /// 250 = 2.5% of the amount paid.
  final int processing_fee_bps;
  final String description;
  final bool is_default;
  @JsonKey(defaultValue: 0)
  final int operators_count;

  RefundPolicy({
    required this.uuid,
    required this.name,
    required this.tiers,
    required this.processing_fee_bps,
    required this.description,
    required this.is_default,
    required this.operators_count,
  });

  factory RefundPolicy.fromJson(Map<String, dynamic> json) =>
      _$RefundPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$RefundPolicyToJson(this);
}

@JsonSerializable()
class Operator {
  final String uuid;
  final String name;
  final int? lead_time_days;
  final String phone_number;
  final String whatsapp;
  final String email;
  final String? refund_policy;
  final String? refund_policy_name;
  @JsonKey(defaultValue: 0)
  final int itineraries_count;

  Operator({
    required this.uuid,
    required this.name,
    this.lead_time_days,
    required this.phone_number,
    required this.whatsapp,
    required this.email,
    this.refund_policy,
    this.refund_policy_name,
    required this.itineraries_count,
  });

  factory Operator.fromJson(Map<String, dynamic> json) =>
      _$OperatorFromJson(json);
  Map<String, dynamic> toJson() => _$OperatorToJson(this);
}

@JsonSerializable()
class Destination {
  final String uuid;
  final String name;
  final String region;
  final String image;
  @JsonKey(defaultValue: 0)
  final int itineraries_count;

  Destination({
    required this.uuid,
    required this.name,
    required this.region,
    required this.image,
    required this.itineraries_count,
  });

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
  Map<String, dynamic> toJson() => _$DestinationToJson(this);
}

@JsonSerializable()
class ItinerarySummary {
  final String uuid;
  final String title;
  final String slug;
  final int duration_days;
  final AccommodationLevel accommodation_level;
  final String operator_uuid;
  final String operator_name;
  final List<String> destinations;
  final List<String> images;
  final bool is_active;
  final bool is_featured;
  final int sort_order;
  final String? base_currency;

  /// Resident adult price in minor units of [base_currency].
  final int? from_price;
  final int goals_count;
  final DateTime updated_at;

  ItinerarySummary({
    required this.uuid,
    required this.title,
    required this.slug,
    required this.duration_days,
    required this.accommodation_level,
    required this.operator_uuid,
    required this.operator_name,
    required this.destinations,
    required this.images,
    required this.is_active,
    required this.is_featured,
    required this.sort_order,
    this.base_currency,
    this.from_price,
    required this.goals_count,
    required this.updated_at,
  });

  factory ItinerarySummary.fromJson(Map<String, dynamic> json) =>
      _$ItinerarySummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ItinerarySummaryToJson(this);
}

@JsonSerializable()
class ItineraryDay {
  int day_number;
  String title;
  @JsonKey(defaultValue: '')
  String description;
  @JsonKey(defaultValue: '')
  String location;
  @JsonKey(defaultValue: [])
  List<String> meals;
  @JsonKey(defaultValue: '')
  String accommodation;

  ItineraryDay({
    required this.day_number,
    required this.title,
    this.description = '',
    this.location = '',
    List<String>? meals,
    this.accommodation = '',
  }) : meals = meals ?? [];

  factory ItineraryDay.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDayFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryDayToJson(this);
}

@JsonSerializable(createToJson: false)
class SeasonalAdjustment {
  DateTime start_date;
  DateTime end_date;

  /// 10000 = 1.0×, 12000 = +20%.
  int multiplier_bps;
  String label;

  SeasonalAdjustment({
    required this.start_date,
    required this.end_date,
    required this.multiplier_bps,
    required this.label,
  });

  factory SeasonalAdjustment.fromJson(Map<String, dynamic> json) =>
      _$SeasonalAdjustmentFromJson(json);
  Map<String, dynamic> toJson() => {
    'start_date': start_date.toIso8601String().substring(0, 10),
    'end_date': end_date.toIso8601String().substring(0, 10),
    'multiplier_bps': multiplier_bps,
    'label': label,
  };
}

@JsonSerializable()
class ItineraryPricing {
  String base_currency;
  int resident_adult;
  int resident_child;
  int non_resident_adult;
  int non_resident_child;
  @JsonKey(defaultValue: [])
  List<SeasonalAdjustment> seasonal_adjustments;

  ItineraryPricing({
    required this.base_currency,
    required this.resident_adult,
    required this.resident_child,
    required this.non_resident_adult,
    required this.non_resident_child,
    required this.seasonal_adjustments,
  });

  factory ItineraryPricing.fromJson(Map<String, dynamic> json) =>
      _$ItineraryPricingFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryPricingToJson(this);
}

@JsonSerializable()
class ItineraryDetail {
  final String uuid;
  final String title;
  final String slug;
  final String summary;
  final int duration_days;
  final AccommodationLevel accommodation_level;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> images;

  /// Operator uuid.
  final String operator;
  final int? lead_time_days;
  final int min_group_size;
  final int max_group_size;
  final bool is_active;
  final bool is_featured;
  final int sort_order;
  final bool kyc_required;

  /// Destination uuids in trip order.
  final List<String> destinations;
  final List<ItineraryDay> days;
  final ItineraryPricing pricing;
  final int goals_count;

  ItineraryDetail({
    required this.uuid,
    required this.title,
    required this.slug,
    required this.summary,
    required this.duration_days,
    required this.accommodation_level,
    required this.inclusions,
    required this.exclusions,
    required this.images,
    required this.operator,
    this.lead_time_days,
    required this.min_group_size,
    required this.max_group_size,
    required this.is_active,
    required this.is_featured,
    required this.sort_order,
    required this.kyc_required,
    required this.destinations,
    required this.days,
    required this.pricing,
    required this.goals_count,
  });

  factory ItineraryDetail.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryDetailToJson(this);
}
