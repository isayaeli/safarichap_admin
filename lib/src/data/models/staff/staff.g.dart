// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffUser _$StaffUserFromJson(Map<String, dynamic> json) => StaffUser(
  uuid: json['uuid'] as String,
  full_name: json['full_name'] as String?,
  email: json['email'] as String?,
  phone_number: json['phone_number'] as String?,
);

Map<String, dynamic> _$StaffUserToJson(StaffUser instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'full_name': instance.full_name,
  'email': instance.email,
  'phone_number': instance.phone_number,
};

RoleRef _$RoleRefFromJson(Map<String, dynamic> json) =>
    RoleRef(uuid: json['uuid'] as String, name: json['name'] as String);

Map<String, dynamic> _$RoleRefToJson(RoleRef instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
};

AdminMe _$AdminMeFromJson(Map<String, dynamic> json) => AdminMe(
  user: StaffUser.fromJson(json['user'] as Map<String, dynamic>),
  roles: (json['roles'] as List<dynamic>)
      .map((e) => RoleRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AdminMeToJson(AdminMe instance) => <String, dynamic>{
  'user': instance.user.toJson(),
  'roles': instance.roles.map((e) => e.toJson()).toList(),
  'permissions': instance.permissions,
};

AdminPermission _$AdminPermissionFromJson(Map<String, dynamic> json) =>
    AdminPermission(
      code: json['code'] as String,
      label: json['label'] as String,
      group: json['group'] as String,
    );

Map<String, dynamic> _$AdminPermissionToJson(AdminPermission instance) =>
    <String, dynamic>{
      'code': instance.code,
      'label': instance.label,
      'group': instance.group,
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  is_system: json['is_system'] as bool? ?? false,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  staff_count: (json['staff_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'description': instance.description,
  'is_system': instance.is_system,
  'permissions': instance.permissions,
  'staff_count': instance.staff_count,
};

StaffMember _$StaffMemberFromJson(Map<String, dynamic> json) => StaffMember(
  uuid: json['uuid'] as String,
  user: StaffUser.fromJson(json['user'] as Map<String, dynamic>),
  roles: (json['roles'] as List<dynamic>)
      .map((e) => RoleRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  is_active: json['is_active'] as bool,
  last_seen_at: json['last_seen_at'] == null
      ? null
      : DateTime.parse(json['last_seen_at'] as String),
  invited_by: json['invited_by'] as String?,
  created_at: DateTime.parse(json['created_at'] as String),
  password_link: json['password_link'] as String?,
);

Map<String, dynamic> _$StaffMemberToJson(StaffMember instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'user': instance.user.toJson(),
      'roles': instance.roles.map((e) => e.toJson()).toList(),
      'is_active': instance.is_active,
      'last_seen_at': instance.last_seen_at?.toIso8601String(),
      'invited_by': instance.invited_by,
      'created_at': instance.created_at.toIso8601String(),
      'password_link': instance.password_link,
    };

AuditActor _$AuditActorFromJson(Map<String, dynamic> json) => AuditActor(
  uuid: json['uuid'] as String,
  full_name: json['full_name'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$AuditActorToJson(AuditActor instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'full_name': instance.full_name,
      'email': instance.email,
    };

AuditLogEntry _$AuditLogEntryFromJson(Map<String, dynamic> json) =>
    AuditLogEntry(
      uuid: json['uuid'] as String,
      actor: json['actor'] == null
          ? null
          : AuditActor.fromJson(json['actor'] as Map<String, dynamic>),
      action: json['action'] as String,
      target_type: json['target_type'] as String,
      target_id: json['target_id'] as String,
      target_label: json['target_label'] as String,
      before: json['before'] as Map<String, dynamic>?,
      after: json['after'] as Map<String, dynamic>?,
      ip_address: json['ip_address'] as String?,
      created_at: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AuditLogEntryToJson(AuditLogEntry instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'actor': instance.actor?.toJson(),
      'action': instance.action,
      'target_type': instance.target_type,
      'target_id': instance.target_id,
      'target_label': instance.target_label,
      'before': instance.before,
      'after': instance.after,
      'ip_address': instance.ip_address,
      'created_at': instance.created_at.toIso8601String(),
    };
