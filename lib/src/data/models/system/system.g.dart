// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminFxRate _$AdminFxRateFromJson(Map<String, dynamic> json) => AdminFxRate(
  uuid: json['uuid'] as String,
  from_currency: json['from_currency'] as String,
  to_currency: json['to_currency'] as String,
  numerator: (json['numerator'] as num).toInt(),
  denominator: (json['denominator'] as num).toInt(),
  source: json['source'] as String,
  fetched_at: DateTime.parse(json['fetched_at'] as String),
);

Map<String, dynamic> _$AdminFxRateToJson(AdminFxRate instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'from_currency': instance.from_currency,
      'to_currency': instance.to_currency,
      'numerator': instance.numerator,
      'denominator': instance.denominator,
      'source': instance.source,
      'fetched_at': instance.fetched_at.toIso8601String(),
    };

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
  default_lead_time_days: (json['default_lead_time_days'] as num).toInt(),
  missed_before_pause: (json['missed_before_pause'] as num).toInt(),
  min_payment_tzs: (json['min_payment_tzs'] as num).toInt(),
  min_payment_other_major: (json['min_payment_other_major'] as num).toInt(),
  reminder_days_before_due: (json['reminder_days_before_due'] as num).toInt(),
  pending_payment_timeout_minutes:
      (json['pending_payment_timeout_minutes'] as num).toInt(),
  packing_list: json['packing_list'] as String,
  updated_at: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AppSettingsToJson(
  AppSettings instance,
) => <String, dynamic>{
  'default_lead_time_days': instance.default_lead_time_days,
  'missed_before_pause': instance.missed_before_pause,
  'min_payment_tzs': instance.min_payment_tzs,
  'min_payment_other_major': instance.min_payment_other_major,
  'reminder_days_before_due': instance.reminder_days_before_due,
  'pending_payment_timeout_minutes': instance.pending_payment_timeout_minutes,
  'packing_list': instance.packing_list,
  'updated_at': instance.updated_at?.toIso8601String(),
};

AdminNotification _$AdminNotificationFromJson(Map<String, dynamic> json) =>
    AdminNotification(
      uuid: json['uuid'] as String,
      user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      is_read: json['is_read'] as bool,
      created_at: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AdminNotificationToJson(AdminNotification instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'user': instance.user.toJson(),
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'is_read': instance.is_read,
      'created_at': instance.created_at.toIso8601String(),
    };

Broadcast _$BroadcastFromJson(Map<String, dynamic> json) => Broadcast(
  uuid: json['uuid'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  audience: json['audience'] as Map<String, dynamic>,
  recipients: (json['recipients'] as num).toInt(),
  sent_by: json['sent_by'] as String?,
  created_at: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BroadcastToJson(Broadcast instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'title': instance.title,
  'message': instance.message,
  'audience': instance.audience,
  'recipients': instance.recipients,
  'sent_by': instance.sent_by,
  'created_at': instance.created_at.toIso8601String(),
};
