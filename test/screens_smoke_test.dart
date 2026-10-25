import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:safarichap_admin/src/core/resources/theme.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';
import 'package:safarichap_admin/src/data/repositories/auth_repository.dart';
import 'package:safarichap_admin/src/routes/app_router.dart';
import 'package:safarichap_admin/src/routes/app_routes.dart';
import 'package:safarichap_admin/src/ui/authentication/sign_in/signin_screen.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/shell/admin_section.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';
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

  /// Pumps the real app router at [location], signed in as [me] (or signed
  /// out). Returns the router so tests can navigate and read the URL.
  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    String location = '/',
    bool signedIn = true,
    List<String>? permissions,
  }) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Get.reset();
    final profile = AdminMe.fromJson({...me, 'permissions': ?permissions});
    final session = Get.put(
      SessionController(_FakeAuth(signedIn), _FakeAccess(profile)),
      permanent: true,
    );
    if (signedIn) session.me.value = profile;
    Get.put(ShellController(sl()), permanent: true);
    final router = createAppRouter(session, initialLocation: location);
    await tester.pumpWidget(
      GetMaterialApp.router(
        theme: buildSafariTheme(isDark: false),
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
    );
    await _settle(tester);
    return router;
  }

  /// What the browser's address bar shows.
  String urlOf(GoRouter router) =>
      router.routeInformationProvider.value.uri.toString();

  testWidgets('every section renders at its URL', (tester) async {
    final router = await pumpApp(tester);
    for (final section in AdminSection.values) {
      router.go(section.path);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: section.name);
      expect(urlOf(router), section.path);
    }
  });

  testWidgets('detail and form pages render at their URLs', (tester) async {
    final router = await pumpApp(tester);
    final pages = [
      AppRoutes.customer(_fixture('user_detail')['uuid']),
      AppRoutes.goal(_fixture('goal_detail')['uuid']),
      AppRoutes.payment(_fixture('payment_detail')['uuid']),
      AppRoutes.booking(_fixture('booking_detail')['uuid']),
      AppRoutes.trip(_fixture('itinerary_detail')['uuid']),
      AppRoutes.newTrip,
    ];
    for (final page in pages) {
      router.go(page);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: page);
      expect(urlOf(router), page);
    }
  });

  testWidgets('narrow window uses the drawer', (tester) async {
    await pumpApp(tester);
    tester.view.physicalSize = const Size(700, 1000);
    await _settle(tester);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('routing', () {
    testWidgets('/ opens the first section', (tester) async {
      final router = await pumpApp(tester);
      expect(urlOf(router), '/overview');
    });

    testWidgets('signed out, a deep link goes to sign-in and remembers it', (
      tester,
    ) async {
      final router = await pumpApp(
        tester,
        location: '/goals/abc',
        signedIn: false,
      );
      expect(urlOf(router), '/sign-in?from=%2Fgoals%2Fabc');
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('a section without permission redirects to an allowed one', (
      tester,
    ) async {
      final router = await pumpApp(
        tester,
        location: '/payments',
        permissions: ['catalogue.view'],
      );
      expect(urlOf(router), '/trips');
    });

    testWidgets('opening a record pushes its URL; back returns to the list', (
      tester,
    ) async {
      final router = await pumpApp(tester, location: '/goals');
      final uuid = _fixture('goal_detail')['uuid'] as String;
      final shell = Get.find<ShellController>();
      shell.open(AppRoutes.goal(uuid));
      await _settle(tester);
      expect(urlOf(router), AppRoutes.goal(uuid));
      shell.back();
      await _settle(tester);
      expect(urlOf(router), '/goals');
    });

    testWidgets('back from a page opened by link goes to its section', (
      tester,
    ) async {
      final uuid = _fixture('user_detail')['uuid'] as String;
      final router = await pumpApp(tester, location: AppRoutes.customer(uuid));
      expect(find.byType(UserDetailsScreen), findsOneWidget);
      Get.find<ShellController>().back();
      await _settle(tester);
      expect(urlOf(router), '/customers');
    });
  });
}

/// Signed in (or not) without Firebase.
class _FakeAuth extends AuthRepository {
  final bool signedIn;
  _FakeAuth(this.signedIn);

  @override
  bool get isSignedIn => signedIn;

  @override
  String? get email => signedIn ? 'staff@safarichap.co.tz' : null;
}

/// Answers /me with [profile] so the session doesn't depend on the fixture's permissions.
class _FakeAccess extends AccessRepository {
  final AdminMe profile;
  _FakeAccess(this.profile) : super(sl());

  @override
  Future<Result<AdminMe>> retrieveMe() async => Success(profile);
}
