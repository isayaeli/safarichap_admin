// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

part 'staff.g.dart';

@JsonSerializable()
class StaffUser {
  final String uuid;
  final String? full_name;
  final String? email;
  final String? phone_number;

  StaffUser({
    required this.uuid,
    this.full_name,
    this.email,
    this.phone_number,
  });

  String get displayName => full_name ?? email ?? phone_number ?? uuid;

  factory StaffUser.fromJson(Map<String, dynamic> json) =>
      _$StaffUserFromJson(json);
  Map<String, dynamic> toJson() => _$StaffUserToJson(this);
}

@JsonSerializable()
class RoleRef {
  final String uuid;
  final String name;

  RoleRef({required this.uuid, required this.name});

  factory RoleRef.fromJson(Map<String, dynamic> json) =>
      _$RoleRefFromJson(json);
  Map<String, dynamic> toJson() => _$RoleRefToJson(this);
}

/// `GET /api/admin/me/`: who is signed in and what they may do.
@JsonSerializable()
class AdminMe {
  final StaffUser user;
  final List<RoleRef> roles;
  final List<String> permissions;

  AdminMe({required this.user, required this.roles, required this.permissions});

  factory AdminMe.fromJson(Map<String, dynamic> json) =>
      _$AdminMeFromJson(json);
  Map<String, dynamic> toJson() => _$AdminMeToJson(this);
}

@JsonSerializable()
class AdminPermission {
  final String code;
  final String label;
  final String group;

  AdminPermission({
    required this.code,
    required this.label,
    required this.group,
  });

  factory AdminPermission.fromJson(Map<String, dynamic> json) =>
      _$AdminPermissionFromJson(json);
  Map<String, dynamic> toJson() => _$AdminPermissionToJson(this);
}

@JsonSerializable()
class Role {
  final String uuid;
  final String name;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: false)
  final bool is_system;
  final List<String> permissions;
  @JsonKey(defaultValue: 0)
  final int staff_count;

  Role({
    required this.uuid,
    required this.name,
    required this.description,
    required this.is_system,
    required this.permissions,
    required this.staff_count,
  });

  /// Super Admin always has every permission and can't be edited.
  bool get isLocked => name == 'Super Admin';

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@JsonSerializable()
class StaffMember {
  final String uuid;
  final StaffUser user;
  final List<RoleRef> roles;
  final bool is_active;
  final DateTime? last_seen_at;
  final String? invited_by;
  final DateTime created_at;

  /// Only in the invite response: the link that sets their password.
  final String? password_link;

  StaffMember({
    required this.uuid,
    required this.user,
    required this.roles,
    required this.is_active,
    this.last_seen_at,
    this.invited_by,
    required this.created_at,
    this.password_link,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);
  Map<String, dynamic> toJson() => _$StaffMemberToJson(this);
}

@JsonSerializable()
class AuditActor {
  final String uuid;
  final String? full_name;
  final String? email;

  AuditActor({required this.uuid, this.full_name, this.email});

  String get displayName => full_name ?? email ?? uuid;

  factory AuditActor.fromJson(Map<String, dynamic> json) =>
      _$AuditActorFromJson(json);
  Map<String, dynamic> toJson() => _$AuditActorToJson(this);
}

@JsonSerializable()
class AuditLogEntry {
  final String uuid;
  final AuditActor? actor;

  /// e.g. `goal.pause`, `role.update`.
  final String action;
  final String target_type;
  final String target_id;
  final String target_label;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? ip_address;
  final DateTime created_at;

  AuditLogEntry({
    required this.uuid,
    this.actor,
    required this.action,
    required this.target_type,
    required this.target_id,
    required this.target_label,
    this.before,
    this.after,
    this.ip_address,
    required this.created_at,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
  Map<String, dynamic> toJson() => _$AuditLogEntryToJson(this);
}
