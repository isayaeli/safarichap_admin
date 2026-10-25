import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:safarichap_admin/src/routes/app_routes.dart';
import 'package:safarichap_admin/src/ui/audit/audit_screen.dart';
import 'package:safarichap_admin/src/ui/authentication/sign_in/signin_screen.dart';
import 'package:safarichap_admin/src/ui/bookings/booking_details_screen.dart';
import 'package:safarichap_admin/src/ui/bookings/bookings_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/destinations/destinations_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/itineraries/itineraries_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/itineraries/itinerary_form_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/operators/operators_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/refund_policies/refund_policies_screen.dart';
import 'package:safarichap_admin/src/ui/fx/fx_screen.dart';
import 'package:safarichap_admin/src/ui/goals/goal_details_screen.dart';
import 'package:safarichap_admin/src/ui/goals/goals_screen.dart';
import 'package:safarichap_admin/src/ui/kyc/kyc_screen.dart';
import 'package:safarichap_admin/src/ui/notifications/notifications_screen.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/onboarding/startup_screens.dart';
import 'package:safarichap_admin/src/ui/overview/overview_screen.dart';
import 'package:safarichap_admin/src/ui/payments/payment_details_screen.dart';
import 'package:safarichap_admin/src/ui/payments/payments_screen.dart';
import 'package:safarichap_admin/src/ui/refunds/refunds_screen.dart';
import 'package:safarichap_admin/src/ui/roles/roles_screen.dart';
import 'package:safarichap_admin/src/ui/settings/settings_screen.dart';
import 'package:safarichap_admin/src/ui/shell/admin_section.dart';
import 'package:safarichap_admin/src/ui/shell/shell_screen.dart';
import 'package:safarichap_admin/src/ui/staff/staff_screen.dart';
import 'package:safarichap_admin/src/ui/users/user_details_screen.dart';
import 'package:safarichap_admin/src/ui/users/users_screen.dart';

/// The app's router, set by [createAppRouter]. `ShellController` navigates through it.
late GoRouter appRouter;

/// Every page has a URL. Sections and their detail pages render inside
/// [ShellScreen]; sign-in, loading and no-access are full-screen.
/// [redirect] keeps signed-out users on sign-in and users on sections they can view.
GoRouter createAppRouter(
  SessionController session, {
  String initialLocation = '/',
}) {
  // Pushed detail pages update the address bar too (go_router's default doesn't).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  GoRoute section(
    AdminSection s,
    Widget Function() list, [
    List<RouteBase> details = const [],
  ]) => GoRoute(
    path: s.path,
    pageBuilder: (context, state) =>
        NoTransitionPage(key: state.pageKey, child: list()),
    routes: details,
  );

  GoRoute detail(String path, Widget Function(String uuid) build) => GoRoute(
    path: path,
    builder: (context, state) => build(state.pathParameters['uuid']!),
  );

  return appRouter = GoRouter(
    // Get.dialog, snackbars and closeDialog() use the root navigator via Get.key.
    navigatorKey: Get.key,
    observers: [GetObserver()],
    initialLocation: initialLocation,
    refreshListenable: session.routerRefresh,
    redirect: (context, state) => _redirect(session, state),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => _firstSection(session)),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: AppRoutes.loading,
        builder: (_, _) => const LoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.noAccess,
        builder: (_, _) => const NoAccessScreen(),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) =>
            ShellScreen(location: state.uri.path, child: child),
        routes: [
          section(AdminSection.overview, () => const OverviewScreen()),
          section(AdminSection.users, () => const UsersScreen(), [
            detail(':uuid', (uuid) => UserDetailsScreen(uuid: uuid)),
          ]),
          section(AdminSection.kyc, () => const KycScreen()),
          section(AdminSection.goals, () => const GoalsScreen(), [
            detail(':uuid', (uuid) => GoalDetailsScreen(uuid: uuid)),
          ]),
          section(AdminSection.payments, () => const PaymentsScreen(), [
            detail(':uuid', (uuid) => PaymentDetailsScreen(uuid: uuid)),
          ]),
          section(AdminSection.refunds, () => const RefundsScreen()),
          section(AdminSection.bookings, () => const BookingsScreen(), [
            detail(':uuid', (uuid) => BookingDetailsScreen(uuid: uuid)),
          ]),
          section(AdminSection.itineraries, () => const ItinerariesScreen(), [
            // Before ':uuid', or "new" would be read as a trip id.
            GoRoute(
              path: 'new',
              builder: (_, _) => const ItineraryFormScreen(),
            ),
            detail(':uuid', (uuid) => ItineraryFormScreen(uuid: uuid)),
          ]),
          section(AdminSection.operators, () => const OperatorsScreen()),
          section(AdminSection.destinations, () => const DestinationsScreen()),
          section(
            AdminSection.refundPolicies,
            () => const RefundPoliciesScreen(),
          ),
          section(
            AdminSection.notifications,
            () => const NotificationsScreen(),
          ),
          section(AdminSection.fx, () => const FxScreen()),
          section(AdminSection.settings, () => const SettingsScreen()),
          section(AdminSection.staff, () => const StaffScreen()),
          section(AdminSection.roles, () => const RolesScreen()),
          section(AdminSection.audit, () => const AuditScreen()),
        ],
      ),
    ],
  );
}

/// The first section in side-nav order the staff member may view.
String _firstSection(SessionController session) {
  final first = AdminSection.values.firstWhereOrNull(
    (s) => session.can(s.permission),
  );
  return first?.path ?? AppRoutes.noAccess;
}

String? _redirect(SessionController session, GoRouterState state) {
  final path = state.uri.path;
  // Where to go once signed in: the page originally asked for.
  final from = state.uri.queryParameters['from'];
  final here = state.uri.toString();
  final keep = path == '/' || path == AppRoutes.signIn ? null : here;
  String withFrom(String target, String? next) => next == null
      ? target
      : Uri(path: target, queryParameters: {'from': next}).toString();

  if (!session.isSignedIn) {
    if (path == AppRoutes.signIn) return null;
    return withFrom(AppRoutes.signIn, keep);
  }

  if (session.me.value == null) {
    if (session.noAccess.value) {
      return path == AppRoutes.noAccess ? null : AppRoutes.noAccess;
    }
    if (path == AppRoutes.loading) return null;
    final next = from ?? (path == AppRoutes.noAccess ? null : keep);
    return withFrom(AppRoutes.loading, next);
  }

  // Signed in with a staff profile: leave the startup pages.
  if (path == AppRoutes.signIn ||
      path == AppRoutes.loading ||
      path == AppRoutes.noAccess) {
    if (from != null && from.startsWith('/') && !from.startsWith('//')) {
      return from;
    }
    return _firstSection(session);
  }

  final section = AdminSection.fromLocation(path);
  if (section != null && !session.can(section.permission)) {
    return _firstSection(session);
  }
  return null;
}
