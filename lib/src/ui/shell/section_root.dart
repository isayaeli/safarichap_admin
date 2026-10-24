import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/ui/audit/audit_screen.dart';
import 'package:safarichap_admin/src/ui/bookings/bookings_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/destinations/destinations_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/itineraries/itineraries_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/operators/operators_screen.dart';
import 'package:safarichap_admin/src/ui/catalogue/refund_policies/refund_policies_screen.dart';
import 'package:safarichap_admin/src/ui/fx/fx_screen.dart';
import 'package:safarichap_admin/src/ui/goals/goals_screen.dart';
import 'package:safarichap_admin/src/ui/kyc/kyc_screen.dart';
import 'package:safarichap_admin/src/ui/notifications/notifications_screen.dart';
import 'package:safarichap_admin/src/ui/overview/overview_screen.dart';
import 'package:safarichap_admin/src/ui/payments/payments_screen.dart';
import 'package:safarichap_admin/src/ui/refunds/refunds_screen.dart';
import 'package:safarichap_admin/src/ui/roles/roles_screen.dart';
import 'package:safarichap_admin/src/ui/settings/settings_screen.dart';
import 'package:safarichap_admin/src/ui/staff/staff_screen.dart';
import 'package:safarichap_admin/src/ui/users/users_screen.dart';

import 'admin_section.dart';
import 'shell_controller.dart';

/// The content navigator's first page: the selected section's list screen.
/// Keyed by section so each switch builds a fresh screen (and controller).
class SectionRoot extends StatelessWidget {
  const SectionRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final ShellController shell = Get.find();
    return Obx(() {
      final section = shell.section.value;
      return KeyedSubtree(key: ValueKey(section), child: _screenFor(section));
    });
  }

  Widget _screenFor(AdminSection section) => switch (section) {
    AdminSection.overview => const OverviewScreen(),
    AdminSection.users => const UsersScreen(),
    AdminSection.kyc => const KycScreen(),
    AdminSection.goals => const GoalsScreen(),
    AdminSection.payments => const PaymentsScreen(),
    AdminSection.refunds => const RefundsScreen(),
    AdminSection.bookings => const BookingsScreen(),
    AdminSection.itineraries => const ItinerariesScreen(),
    AdminSection.operators => const OperatorsScreen(),
    AdminSection.destinations => const DestinationsScreen(),
    AdminSection.refundPolicies => const RefundPoliciesScreen(),
    AdminSection.notifications => const NotificationsScreen(),
    AdminSection.fx => const FxScreen(),
    AdminSection.settings => const SettingsScreen(),
    AdminSection.staff => const StaffScreen(),
    AdminSection.roles => const RolesScreen(),
    AdminSection.audit => const AuditScreen(),
  };
}
