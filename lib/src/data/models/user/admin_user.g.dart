// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRef _$UserRefFromJson(Map<String, dynamic> json) => UserRef(
  uuid: json['uuid'] as String,
  full_name: json['full_name'] as String?,
  phone_number: json['phone_number'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$UserRefToJson(UserRef instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'full_name': instance.full_name,
  'phone_number': instance.phone_number,
  'email': instance.email,
};

AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => AdminUser(
  uuid: json['uuid'] as String,
  full_name: json['full_name'] as String?,
  phone_number: json['phone_number'] as String?,
  email: json['email'] as String?,
  residency: $enumDecodeNullable(_$ResidencyEnumMap, json['residency']),
  preferred_currency: json['preferred_currency'] as String?,
  country: json['country'] as String,
  kyc_status: $enumDecode(_$KycStatusEnumMap, json['kyc_status']),
  notifications_enabled: json['notifications_enabled'] as bool,
  is_active: json['is_active'] as bool,
  is_staff: json['is_staff'] as bool,
  last_login: json['last_login'] == null
      ? null
      : DateTime.parse(json['last_login'] as String),
  created_at: DateTime.parse(json['created_at'] as String),
  goals_count: (json['goals_count'] as num?)?.toInt() ?? 0,
  active_goals_count: (json['active_goals_count'] as num?)?.toInt() ?? 0,
  goals:
      (json['goals'] as List<dynamic>?)
          ?.map((e) => GoalSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => AdminPayment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  devices:
      (json['devices'] as List<dynamic>?)
          ?.map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  kyc_documents:
      (json['kyc_documents'] as List<dynamic>?)
          ?.map((e) => KycDocument.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$AdminUserToJson(AdminUser instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'full_name': instance.full_name,
  'phone_number': instance.phone_number,
  'email': instance.email,
  'residency': _$ResidencyEnumMap[instance.residency],
  'preferred_currency': instance.preferred_currency,
  'country': instance.country,
  'kyc_status': _$KycStatusEnumMap[instance.kyc_status]!,
  'notifications_enabled': instance.notifications_enabled,
  'is_active': instance.is_active,
  'is_staff': instance.is_staff,
  'last_login': instance.last_login?.toIso8601String(),
  'created_at': instance.created_at.toIso8601String(),
  'goals_count': instance.goals_count,
  'active_goals_count': instance.active_goals_count,
  'goals': instance.goals.map((e) => e.toJson()).toList(),
  'payments': instance.payments.map((e) => e.toJson()).toList(),
  'devices': instance.devices.map((e) => e.toJson()).toList(),
  'kyc_documents': instance.kyc_documents.map((e) => e.toJson()).toList(),
};

const _$ResidencyEnumMap = {
  Residency.resident: 'resident',
  Residency.nonResident: 'non_resident',
};

const _$KycStatusEnumMap = {
  KycStatus.notRequired: 'not_required',
  KycStatus.pending: 'pending',
  KycStatus.verified: 'verified',
  KycStatus.rejected: 'rejected',
};

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  uuid: json['uuid'] as String,
  platform: json['platform'] as String,
  notifications_enabled: json['notifications_enabled'] as bool,
  created_at: DateTime.parse(json['created_at'] as String),
  updated_at: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'platform': instance.platform,
  'notifications_enabled': instance.notifications_enabled,
  'created_at': instance.created_at.toIso8601String(),
  'updated_at': instance.updated_at.toIso8601String(),
};

KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) => KycDocument(
  uuid: json['uuid'] as String,
  user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
  document_type: $enumDecode(_$KycDocumentTypeEnumMap, json['document_type']),
  document_number: json['document_number'] as String,
  status: $enumDecode(_$KycStatusEnumMap, json['status']),
  review_note: json['review_note'] as String? ?? '',
  reviewed_at: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  reviewed_by: json['reviewed_by'] as String?,
  created_at: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$KycDocumentToJson(KycDocument instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'user': instance.user.toJson(),
      'document_type': _$KycDocumentTypeEnumMap[instance.document_type]!,
      'document_number': instance.document_number,
      'status': _$KycStatusEnumMap[instance.status]!,
      'review_note': instance.review_note,
      'reviewed_at': instance.reviewed_at?.toIso8601String(),
      'reviewed_by': instance.reviewed_by,
      'created_at': instance.created_at.toIso8601String(),
    };

const _$KycDocumentTypeEnumMap = {
  KycDocumentType.nida: 'nida',
  KycDocumentType.passport: 'passport',
};
