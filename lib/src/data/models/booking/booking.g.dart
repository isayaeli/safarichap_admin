// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripDocument _$TripDocumentFromJson(Map<String, dynamic> json) => TripDocument(
  uuid: json['uuid'] as String,
  type: $enumDecode(_$TripDocumentTypeEnumMap, json['type']),
  title: json['title'] as String,
  url: json['url'] as String?,
  content: json['content'] as String?,
  position: (json['position'] as num).toInt(),
  created_at: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TripDocumentToJson(TripDocument instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'type': _$TripDocumentTypeEnumMap[instance.type]!,
      'title': instance.title,
      'url': instance.url,
      'content': instance.content,
      'position': instance.position,
      'created_at': instance.created_at.toIso8601String(),
    };

const _$TripDocumentTypeEnumMap = {
  TripDocumentType.voucher: 'voucher',
  TripDocumentType.packingList: 'packing_list',
  TripDocumentType.operatorContacts: 'operator_contacts',
  TripDocumentType.other: 'other',
};

AdminBooking _$AdminBookingFromJson(Map<String, dynamic> json) => AdminBooking(
  uuid: json['uuid'] as String,
  confirmation_code: json['confirmation_code'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  travel_date: DateTime.parse(json['travel_date'] as String),
  user: UserRef.fromJson(json['user'] as Map<String, dynamic>),
  goal_uuid: json['goal_uuid'] as String,
  itinerary_title: json['itinerary_title'] as String,
  operator_name: json['operator_name'] as String,
  travellers: (json['travellers'] as num).toInt(),
  created_at: DateTime.parse(json['created_at'] as String),
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => TripDocument.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$AdminBookingToJson(AdminBooking instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'confirmation_code': instance.confirmation_code,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'travel_date': instance.travel_date.toIso8601String(),
      'user': instance.user.toJson(),
      'goal_uuid': instance.goal_uuid,
      'itinerary_title': instance.itinerary_title,
      'operator_name': instance.operator_name,
      'travellers': instance.travellers,
      'created_at': instance.created_at.toIso8601String(),
      'documents': instance.documents.map((e) => e.toJson()).toList(),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};
