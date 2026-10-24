// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefundTier _$RefundTierFromJson(Map<String, dynamic> json) => RefundTier(
  min_days: (json['min_days'] as num).toInt(),
  percentage: (json['percentage'] as num).toInt(),
);

Map<String, dynamic> _$RefundTierToJson(RefundTier instance) =>
    <String, dynamic>{
      'min_days': instance.min_days,
      'percentage': instance.percentage,
    };

RefundPolicy _$RefundPolicyFromJson(Map<String, dynamic> json) => RefundPolicy(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  tiers: (json['tiers'] as List<dynamic>)
      .map((e) => RefundTier.fromJson(e as Map<String, dynamic>))
      .toList(),
  processing_fee_bps: (json['processing_fee_bps'] as num).toInt(),
  description: json['description'] as String,
  is_default: json['is_default'] as bool,
  operators_count: (json['operators_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RefundPolicyToJson(RefundPolicy instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'tiers': instance.tiers.map((e) => e.toJson()).toList(),
      'processing_fee_bps': instance.processing_fee_bps,
      'description': instance.description,
      'is_default': instance.is_default,
      'operators_count': instance.operators_count,
    };

Operator _$OperatorFromJson(Map<String, dynamic> json) => Operator(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  lead_time_days: (json['lead_time_days'] as num?)?.toInt(),
  phone_number: json['phone_number'] as String,
  whatsapp: json['whatsapp'] as String,
  email: json['email'] as String,
  refund_policy: json['refund_policy'] as String?,
  refund_policy_name: json['refund_policy_name'] as String?,
  itineraries_count: (json['itineraries_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OperatorToJson(Operator instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'lead_time_days': instance.lead_time_days,
  'phone_number': instance.phone_number,
  'whatsapp': instance.whatsapp,
  'email': instance.email,
  'refund_policy': instance.refund_policy,
  'refund_policy_name': instance.refund_policy_name,
  'itineraries_count': instance.itineraries_count,
};

Destination _$DestinationFromJson(Map<String, dynamic> json) => Destination(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  region: json['region'] as String,
  image: json['image'] as String,
  itineraries_count: (json['itineraries_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'region': instance.region,
      'image': instance.image,
      'itineraries_count': instance.itineraries_count,
    };

ItinerarySummary _$ItinerarySummaryFromJson(Map<String, dynamic> json) =>
    ItinerarySummary(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      duration_days: (json['duration_days'] as num).toInt(),
      accommodation_level: $enumDecode(
        _$AccommodationLevelEnumMap,
        json['accommodation_level'],
      ),
      operator_uuid: json['operator_uuid'] as String,
      operator_name: json['operator_name'] as String,
      destinations: (json['destinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      is_active: json['is_active'] as bool,
      is_featured: json['is_featured'] as bool,
      sort_order: (json['sort_order'] as num).toInt(),
      base_currency: json['base_currency'] as String?,
      from_price: (json['from_price'] as num?)?.toInt(),
      goals_count: (json['goals_count'] as num).toInt(),
      updated_at: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ItinerarySummaryToJson(ItinerarySummary instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'title': instance.title,
      'slug': instance.slug,
      'duration_days': instance.duration_days,
      'accommodation_level':
          _$AccommodationLevelEnumMap[instance.accommodation_level]!,
      'operator_uuid': instance.operator_uuid,
      'operator_name': instance.operator_name,
      'destinations': instance.destinations,
      'images': instance.images,
      'is_active': instance.is_active,
      'is_featured': instance.is_featured,
      'sort_order': instance.sort_order,
      'base_currency': instance.base_currency,
      'from_price': instance.from_price,
      'goals_count': instance.goals_count,
      'updated_at': instance.updated_at.toIso8601String(),
    };

const _$AccommodationLevelEnumMap = {
  AccommodationLevel.budget: 'budget',
  AccommodationLevel.midRange: 'mid_range',
  AccommodationLevel.luxury: 'luxury',
};

ItineraryDay _$ItineraryDayFromJson(Map<String, dynamic> json) => ItineraryDay(
  day_number: (json['day_number'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  location: json['location'] as String? ?? '',
  meals:
      (json['meals'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  accommodation: json['accommodation'] as String? ?? '',
);

Map<String, dynamic> _$ItineraryDayToJson(ItineraryDay instance) =>
    <String, dynamic>{
      'day_number': instance.day_number,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'meals': instance.meals,
      'accommodation': instance.accommodation,
    };

SeasonalAdjustment _$SeasonalAdjustmentFromJson(Map<String, dynamic> json) =>
    SeasonalAdjustment(
      start_date: DateTime.parse(json['start_date'] as String),
      end_date: DateTime.parse(json['end_date'] as String),
      multiplier_bps: (json['multiplier_bps'] as num).toInt(),
      label: json['label'] as String,
    );

ItineraryPricing _$ItineraryPricingFromJson(Map<String, dynamic> json) =>
    ItineraryPricing(
      base_currency: json['base_currency'] as String,
      resident_adult: (json['resident_adult'] as num).toInt(),
      resident_child: (json['resident_child'] as num).toInt(),
      non_resident_adult: (json['non_resident_adult'] as num).toInt(),
      non_resident_child: (json['non_resident_child'] as num).toInt(),
      seasonal_adjustments:
          (json['seasonal_adjustments'] as List<dynamic>?)
              ?.map(
                (e) => SeasonalAdjustment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$ItineraryPricingToJson(ItineraryPricing instance) =>
    <String, dynamic>{
      'base_currency': instance.base_currency,
      'resident_adult': instance.resident_adult,
      'resident_child': instance.resident_child,
      'non_resident_adult': instance.non_resident_adult,
      'non_resident_child': instance.non_resident_child,
      'seasonal_adjustments': instance.seasonal_adjustments
          .map((e) => e.toJson())
          .toList(),
    };

ItineraryDetail _$ItineraryDetailFromJson(
  Map<String, dynamic> json,
) => ItineraryDetail(
  uuid: json['uuid'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String,
  summary: json['summary'] as String,
  duration_days: (json['duration_days'] as num).toInt(),
  accommodation_level: $enumDecode(
    _$AccommodationLevelEnumMap,
    json['accommodation_level'],
  ),
  inclusions: (json['inclusions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  exclusions: (json['exclusions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  operator: json['operator'] as String,
  lead_time_days: (json['lead_time_days'] as num?)?.toInt(),
  min_group_size: (json['min_group_size'] as num).toInt(),
  max_group_size: (json['max_group_size'] as num).toInt(),
  is_active: json['is_active'] as bool,
  is_featured: json['is_featured'] as bool,
  sort_order: (json['sort_order'] as num).toInt(),
  kyc_required: json['kyc_required'] as bool,
  destinations: (json['destinations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  days: (json['days'] as List<dynamic>)
      .map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
      .toList(),
  pricing: ItineraryPricing.fromJson(json['pricing'] as Map<String, dynamic>),
  goals_count: (json['goals_count'] as num).toInt(),
);

Map<String, dynamic> _$ItineraryDetailToJson(ItineraryDetail instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'title': instance.title,
      'slug': instance.slug,
      'summary': instance.summary,
      'duration_days': instance.duration_days,
      'accommodation_level':
          _$AccommodationLevelEnumMap[instance.accommodation_level]!,
      'inclusions': instance.inclusions,
      'exclusions': instance.exclusions,
      'images': instance.images,
      'operator': instance.operator,
      'lead_time_days': instance.lead_time_days,
      'min_group_size': instance.min_group_size,
      'max_group_size': instance.max_group_size,
      'is_active': instance.is_active,
      'is_featured': instance.is_featured,
      'sort_order': instance.sort_order,
      'kyc_required': instance.kyc_required,
      'destinations': instance.destinations,
      'days': instance.days.map((e) => e.toJson()).toList(),
      'pricing': instance.pricing.toJson(),
      'goals_count': instance.goals_count,
    };
