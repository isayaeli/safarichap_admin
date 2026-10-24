// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../user/admin_user.dart';

part 'system.g.dart';

/// 1 [from_currency] = numerator / denominator TZS.
@JsonSerializable()
class AdminFxRate {
  final String uuid;
  final String from_currency;
  final String to_currency;
  final int numerator;
  final int denominator;
  final String source;
  final DateTime fetched_at;

  AdminFxRate({
    required this.uuid,
    required this.from_currency,
    required this.to_currency,
    required this.numerator,
    required this.denominator,
    required this.source,
    required this.fetched_at,
  });

  bool get isManual => source.startsWith('manual');

  /// Shown only, never used for money arithmetic.
  String get display {
    final value = numerator / denominator;
    return value.toStringAsFixed(value >= 100 ? 2 : 4);
  }

  factory AdminFxRate.fromJson(Map<String, dynamic> json) =>
      _$AdminFxRateFromJson(json);
  Map<String, dynamic> toJson() => _$AdminFxRateToJson(this);
}

@JsonSerializable()
class AppSettings {
  final int default_lead_time_days;
  final int missed_before_pause;

  /// Whole shillings.
  final int min_payment_tzs;

  /// Major units of USD/EUR/GBP.
  final int min_payment_other_major;
  final int reminder_days_before_due;
  final int pending_payment_timeout_minutes;
  final String packing_list;
  final DateTime? updated_at;

  AppSettings({
    required this.default_lead_time_days,
    required this.missed_before_pause,
    required this.min_payment_tzs,
    required this.min_payment_other_major,
    required this.reminder_days_before_due,
    required this.pending_payment_timeout_minutes,
    required this.packing_list,
    this.updated_at,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);
}

@JsonSerializable()
class AdminNotification {
  final String uuid;
  final UserRef user;
  final String title;
  final String message;
  final String type;
  final bool is_read;
  final DateTime created_at;

  AdminNotification({
    required this.uuid,
    required this.user,
    required this.title,
    required this.message,
    required this.type,
    required this.is_read,
    required this.created_at,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) =>
      _$AdminNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AdminNotificationToJson(this);
}

@JsonSerializable()
class Broadcast {
  final String uuid;
  final String title;
  final String message;
  final Map<String, dynamic> audience;
  final int recipients;
  final String? sent_by;
  final DateTime created_at;

  Broadcast({
    required this.uuid,
    required this.title,
    required this.message,
    required this.audience,
    required this.recipients,
    this.sent_by,
    required this.created_at,
  });

  factory Broadcast.fromJson(Map<String, dynamic> json) =>
      _$BroadcastFromJson(json);
  Map<String, dynamic> toJson() => _$BroadcastToJson(this);
}
