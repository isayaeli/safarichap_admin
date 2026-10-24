import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:safarichap_admin/src/data/models/booking/booking.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/payment/payment.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/models/stats/stats.dart';
import 'package:safarichap_admin/src/data/models/system/system.dart';
import 'package:safarichap_admin/src/data/models/user/admin_user.dart';

/// Every model parses a real API response. Fixtures are recorded from the
/// Django test suite with tool/api_fixtures_test.py; re-record them when the
/// admin API changes.
dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync());

Paginated<T> page<T>(String name, T Function(Map<String, dynamic>) fromJson) {
  final p = Paginated.fromJson(fixture(name), fromJson);
  expect(p.results, isNotEmpty, reason: '$name has no rows');
  return p;
}

void main() {
  test('access: me, permissions, roles, staff, audit log', () {
    final me = AdminMe.fromJson(fixture('me'));
    expect(me.roles.single.name, 'Super Admin');
    expect(me.permissions, contains('staff.manage'));

    final perms = (fixture('permissions') as List)
        .map((e) => AdminPermission.fromJson(e))
        .toList();
    expect(perms.map((p) => p.code).toSet(), me.permissions.toSet());

    final roles = page('roles', Role.fromJson).results;
    expect(roles.firstWhere((r) => r.name == 'Super Admin').isLocked, isTrue);
    expect(roles.firstWhere((r) => r.name == 'Auditor').is_system, isFalse);

    page('staff', StaffMember.fromJson);
    final audit = page('audit_logs', AuditLogEntry.fromJson).results;
    expect(audit.map((e) => e.action), contains('role.create'));
  });

  test('customers and KYC', () {
    final users = page('users', AdminUser.fromJson);
    expect(users.count, greaterThan(0));
    final detail = AdminUser.fromJson(fixture('user_detail'));
    expect(detail.goals, isNotEmpty);
    expect(detail.payments, isNotEmpty);
    final kyc = page('kyc', KycDocument.fromJson).results.first;
    expect(kyc.status, KycStatus.pending);
    expect(kyc.document_type, KycDocumentType.passport);
  });

  test('goals, payments, refunds, bookings', () {
    final goals = page('goals', GoalSummary.fromJson).results;
    expect(
      goals.map((g) => g.status),
      containsAll([GoalStatus.completed, GoalStatus.cancelled]),
    );
    final goal = GoalDetail.fromJson(fixture('goal_detail'));
    expect(goal.installments, isNotEmpty);
    expect(goal.refunds.single.status, RefundStatus.pending);
    expect(goal.paid.minor, goal.amount_paid);

    page('payments', AdminPayment.fromJson);
    final payment = AdminPayment.fromJson(fixture('payment_detail'));
    expect(payment.status, PaymentStatus.success);
    expect(payment.raw_webhook, isNotNull);
    page('refunds', AdminRefund.fromJson);

    page('bookings', AdminBooking.fromJson);
    final booking = AdminBooking.fromJson(fixture('booking_detail'));
    expect(booking.documents, isNotEmpty);
  });

  test('catalogue', () {
    page('operators', Operator.fromJson);
    page('destinations', Destination.fromJson);
    expect(
      Paginated.fromJson(
        fixture('refund_policies'),
        RefundPolicy.fromJson,
      ).results,
      isA<List<RefundPolicy>>(),
    );
    page('itineraries', ItinerarySummary.fromJson);
    final trip = ItineraryDetail.fromJson(fixture('itinerary_detail'));
    expect(trip.destinations, isNotEmpty);
    expect(trip.pricing.resident_adult, greaterThan(0));
  });

  test('system: stats, FX, settings, notifications', () {
    final stats = AdminStats.fromJson(fixture('stats'));
    expect(stats.collected, isNotEmpty);
    expect(stats.collectionsSeries, isNotEmpty);
    final fx = (fixture('fx_current') as List)
        .map((e) => AdminFxRate.fromJson(e))
        .toList();
    expect(fx.firstWhere((r) => r.from_currency == 'USD').isManual, isTrue);
    page('fx_rates', AdminFxRate.fromJson);
    AppSettings.fromJson(fixture('settings'));
    page('notifications', AdminNotification.fromJson);
    expect(
      page('broadcasts', Broadcast.fromJson).results.single.recipients,
      greaterThan(0),
    );
  });
}
