// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';

import '../enums.dart';
import '../user/admin_user.dart';

part 'booking.g.dart';

@JsonSerializable()
class TripDocument {
  final String uuid;
  final TripDocumentType type;
  final String title;
  final String? url;
  final String? content;
  final int position;
  final DateTime created_at;

  TripDocument({
    required this.uuid,
    required this.type,
    required this.title,
    this.url,
    this.content,
    required this.position,
    required this.created_at,
  });

  factory TripDocument.fromJson(Map<String, dynamic> json) =>
      _$TripDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$TripDocumentToJson(this);
}

@JsonSerializable()
class AdminBooking {
  final String uuid;
  final String confirmation_code;
  final BookingStatus status;
  final DateTime travel_date;
  final UserRef user;
  final String goal_uuid;
  final String itinerary_title;
  final String operator_name;
  final int travellers;
  final DateTime created_at;

  /// Detail only.
  @JsonKey(defaultValue: [])
  final List<TripDocument> documents;

  AdminBooking({
    required this.uuid,
    required this.confirmation_code,
    required this.status,
    required this.travel_date,
    required this.user,
    required this.goal_uuid,
    required this.itinerary_title,
    required this.operator_name,
    required this.travellers,
    required this.created_at,
    required this.documents,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) =>
      _$AdminBookingFromJson(json);
  Map<String, dynamic> toJson() => _$AdminBookingToJson(this);
}
