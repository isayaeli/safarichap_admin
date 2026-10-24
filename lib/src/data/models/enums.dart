import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';

// API values are the `wire` strings (snake_case, as served by Django).

@JsonEnum(valueField: 'wire')
enum Residency {
  resident('resident', 'Resident'),
  nonResident('non_resident', 'Non-resident');

  const Residency(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum AgeCategory {
  adult('adult', 'Adult'),
  child('child', 'Child');

  const AgeCategory(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum AccommodationLevel {
  budget('budget', 'Budget'),
  midRange('mid_range', 'Mid-range'),
  luxury('luxury', 'Luxury');

  const AccommodationLevel(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum GoalStatus {
  draft('draft', 'Draft'),
  active('active', 'Active'),
  paused('paused', 'Paused'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  expired('expired', 'Expired');

  const GoalStatus(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;

  bool get acceptsPayments => this == active || this == paused;
}

@JsonEnum(valueField: 'wire')
enum PaymentFrequency {
  weekly('weekly', 'Weekly', 7),
  biWeekly('bi_weekly', 'Every 2 weeks', 14),
  monthly('monthly', 'Monthly', 0),
  custom('custom', 'Custom', 0);

  const PaymentFrequency(this.wire, this._label, this.periodDays);
  final String wire;
  final String _label;

  String get label => _label.tr;

  /// Fixed period length in days; 0 for calendar-based (monthly) or custom.
  final int periodDays;
}

@JsonEnum(valueField: 'wire')
enum InstallmentStatus {
  upcoming('upcoming', 'Upcoming'),
  paid('paid', 'Paid'),
  partiallyPaid('partially_paid', 'Partially paid'),
  missed('missed', 'Missed');

  const InstallmentStatus(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum PaymentMethod {
  mpesa('mpesa', 'M-Pesa', true),
  airtelMoney('airtel_money', 'Airtel Money', true),
  mixxByYas('mixx_by_yas', 'Mixx by Yas', true),
  haloPesa('halo_pesa', 'HaloPesa', true),
  card('card', 'Card', false);

  const PaymentMethod(this.wire, this._label, this.isMobileMoney);
  final String wire;
  final String _label;

  String get label => _label.tr;
  final bool isMobileMoney;

  static List<PaymentMethod> get mobileMoney =>
      values.where((m) => m.isMobileMoney).toList();
}

@JsonEnum(valueField: 'wire')
enum PaymentStatus {
  pending('pending', 'Pending'),
  success('success', 'Successful'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded');

  const PaymentStatus(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;

  bool get isFinal => this != pending;
}

@JsonEnum(valueField: 'wire')
enum BookingStatus {
  confirmed('confirmed', 'Confirmed'),
  cancelled('cancelled', 'Cancelled'),
  completed('completed', 'Completed');

  const BookingStatus(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum KycStatus {
  notRequired('not_required', 'Not required'),
  pending('pending', 'Pending review'),
  verified('verified', 'Verified'),
  rejected('rejected', 'Rejected');

  const KycStatus(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum TripDocumentType {
  voucher('voucher', 'Voucher'),
  packingList('packing_list', 'Packing list'),
  operatorContacts('operator_contacts', 'Operator contacts'),
  other('other', 'Document');

  const TripDocumentType(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

@JsonEnum(valueField: 'wire')
enum RefundStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed');

  const RefundStatus(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;

  bool get canProcess => this == pending || this == failed;
}

@JsonEnum(valueField: 'wire')
enum KycDocumentType {
  nida('nida', 'NIDA'),
  passport('passport', 'Passport');

  const KycDocumentType(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}

/// Who receives a broadcast.
enum BroadcastAudience {
  all('all', 'All customers'),
  residency('residency', 'By residency'),
  goalStatus('goal_status', 'By goal status'),
  users('users', 'Specific customers');

  const BroadcastAudience(this.wire, this._label);
  final String wire;
  final String _label;

  String get label => _label.tr;
}
