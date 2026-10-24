// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../enums.dart';
import '../goal/goal.dart';
import '../payment/payment.dart';

part 'admin_user.g.dart';

/// Short user reference embedded in goals, payments, bookings and KYC.
@JsonSerializable()
class UserRef {
  final String uuid;
  final String? full_name;
  final String? phone_number;
  final String? email;

  UserRef({required this.uuid, this.full_name, this.phone_number, this.email});

  String get displayName => full_name ?? phone_number ?? email ?? '-';

  factory UserRef.fromJson(Map<String, dynamic> json) =>
      _$UserRefFromJson(json);
  Map<String, dynamic> toJson() => _$UserRefToJson(this);
}

@JsonSerializable()
class AdminUser {
  final String uuid;
  final String? full_name;
  final String? phone_number;
  final String? email;
  final Residency? residency;
  final String? preferred_currency;
  final String country;
  final KycStatus kyc_status;
  final bool notifications_enabled;
  final bool is_active;
  final bool is_staff;
  final DateTime? last_login;
  final DateTime created_at;
  @JsonKey(defaultValue: 0)
  final int goals_count;
  @JsonKey(defaultValue: 0)
  final int active_goals_count;

  // Detail only.
  @JsonKey(defaultValue: [])
  final List<GoalSummary> goals;
  @JsonKey(defaultValue: [])
  final List<AdminPayment> payments;
  @JsonKey(defaultValue: [])
  final List<Device> devices;
  @JsonKey(defaultValue: [])
  final List<KycDocument> kyc_documents;

  AdminUser({
    required this.uuid,
    this.full_name,
    this.phone_number,
    this.email,
    this.residency,
    this.preferred_currency,
    required this.country,
    required this.kyc_status,
    required this.notifications_enabled,
    required this.is_active,
    required this.is_staff,
    this.last_login,
    required this.created_at,
    required this.goals_count,
    required this.active_goals_count,
    required this.goals,
    required this.payments,
    required this.devices,
    required this.kyc_documents,
  });

  String get displayName => full_name ?? phone_number ?? email ?? '-';

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
  Map<String, dynamic> toJson() => _$AdminUserToJson(this);
}

@JsonSerializable()
class Device {
  final String uuid;
  final String platform;
  final bool notifications_enabled;
  final DateTime created_at;
  final DateTime updated_at;

  Device({
    required this.uuid,
    required this.platform,
    required this.notifications_enabled,
    required this.created_at,
    required this.updated_at,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class KycDocument {
  final String uuid;
  final UserRef user;
  final KycDocumentType document_type;
  final String document_number;
  final KycStatus status;
  @JsonKey(defaultValue: '')
  final String review_note;
  final DateTime? reviewed_at;
  final String? reviewed_by;
  final DateTime created_at;

  KycDocument({
    required this.uuid,
    required this.user,
    required this.document_type,
    required this.document_number,
    required this.status,
    required this.review_note,
    this.reviewed_at,
    this.reviewed_by,
    required this.created_at,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$KycDocumentToJson(this);
}
