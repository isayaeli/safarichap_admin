import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:safarichap_admin/src/core/resources/theme.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/bookings/booking_details_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/itineraries/itinerary_form_screen.dart';
import 'package:safarichap_admin/src/ui/goals/goal_details_screen.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/payments/payment_details_screen.dart';
import 'package:safarichap_admin/src/ui/shell/admin_section.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
import 'package:safarichap_admin/src/ui/shell/shell_screen.dart';
import 'package:safarichap_admin/src/ui/users/user_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders every section and detail page against the recorded API fixtures
/// (test/fixtures) to catch layout and parsing errors at runtime.
String _fixtureFor(String path) {
  final p = path.replaceFirst('/api/admin/', '');
  final detail = RegExp(r'^([a-z-]+)/[0-9a-f-]{36}/$').firstMatch(p);
  if (detail != null) {
    return switch (detail.group(1)) {
      'users' => 'user_detail',
      'goals' => 'goal_detail',
      'payments' => 'payment_detail',
      'bookings' => 'booking_detail',
      'itineraries' => 'itinerary_detail',
      _ => throw StateError('No fixture for $path'),
    };
  }
  return switch (p) {
    'fx-rates/current/' => 'fx_current',
    'audit-logs/' => 'audit_logs',
    'refund-policies/' => 'refund_policies',
    'fx-rates/' => 'fx_rates',
    _ => p.replaceAll('/', '').replaceAll('-', '_'),
  };
}

/// Loading indicators animate forever, so pump fixed frames instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

dynamic _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync());

void main() {
  late Map<String, dynamic> me;

  /// Requests no fixture answered; a screen calling an unexpected endpoint fails the test.
  final misses = <String>[];
  tearDown(() {
    expect(misses, isEmpty, reason: 'unanswered requests');
    misses.clear();
  });

  setUpAll(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({});
    await initGetIt();
    sl.unregister<AdminClient>();
    sl.registerLazySingleton<AdminClient>(
      () => AdminClient(
        client: MockClient((request) async {
          final File file;
          try {
            file = File('test/fixtures/${_fixtureFor(request.url.path)}.json');
          } catch (_) {
            misses.add(request.url.path);
            return http.Response('{"detail": "no fixture"}', 404);
          }
          if (!file.existsSync()) {
            misses.add(request.url.path);
            return http.Response('{"detail": "no fixture"}', 404);
          }
          final body = file.readAsStringSync();
          return http.Response(
            body,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      ),
    );
    me = _fixture('me') as Map<String, dynamic>;
  });

  Future<ShellController> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Get.reset();
    final session = Get.put(SessionController(sl(), sl()), permanent: true);
    session.me.value = AdminMe.fromJson(me);
    final shell = Get.put(ShellController(sl()), permanent: true);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: buildSafariTheme(isDark: false),
        home: const ShellScreen(),
      ),
    );
    await _settle(tester);
    return shell;
  }

  testWidgets('every section renders', (tester) async {
    final shell = await pumpShell(tester);
    for (final section in AdminSection.values) {
      shell.select(section);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: section.name);
    }
  });

  testWidgets('detail and form pages render', (tester) async {
    final shell = await pumpShell(tester);
    final pages = <Widget>[
      UserDetailsScreen(uuid: _fixture('user_detail')['uuid']),
      GoalDetailsScreen(uuid: _fixture('goal_detail')['uuid']),
      PaymentDetailsScreen(uuid: _fixture('payment_detail')['uuid']),
      BookingDetailsScreen(uuid: _fixture('booking_detail')['uuid']),
      ItineraryFormScreen(uuid: _fixture('itinerary_detail')['uuid']),
      const ItineraryFormScreen(),
    ];
    for (final page in pages) {
      shell.open(page);
      await _settle(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: page.runtimeType.toString(),
      );
      shell.back();
      await _settle(tester);
    }
  });

  testWidgets('narrow window uses the drawer', (tester) async {
    await pumpShell(tester);
    tester.view.physicalSize = const Size(700, 1000);
    await _settle(tester);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
