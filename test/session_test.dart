import 'package:flutter_test/flutter_test.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';
import 'package:safarichap_admin/src/data/repositories/auth_repository.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/shell/admin_section.dart';

void main() {
  SessionController sessionWith(List<String> codes) {
    final session = SessionController(
      AuthRepository(),
      AccessRepository(AdminClient()),
    );
    session.me.value = AdminMe(
      user: StaffUser(uuid: 'u1', full_name: 'Neema'),
      roles: [RoleRef(uuid: 'r1', name: 'Finance')],
      permissions: codes,
    );
    return session;
  }

  test('can() follows the permission codes from /me', () {
    final session = sessionWith(['payments.view', 'refunds.manage']);
    expect(session.can('payments.view'), isTrue);
    expect(session.can('staff.manage'), isFalse);
    expect(session.canAny(['staff.view', 'refunds.manage']), isTrue);
  });

  test('only sections the staff member can view are shown', () {
    final session = sessionWith(['catalogue.view']);
    final visible = AdminSection.values
        .where((s) => session.can(s.permission))
        .toList();
    expect(visible, [
      AdminSection.itineraries,
      AdminSection.operators,
      AdminSection.destinations,
      AdminSection.refundPolicies,
    ]);
  });

  test('every section maps to a real permission code', () {
    const codes = {
      'reports.view',
      'users.view',
      'kyc.view',
      'goals.view',
      'payments.view',
      'refunds.view',
      'bookings.view',
      'catalogue.view',
      'notifications.view',
      'fx.view',
      'settings.view',
      'staff.view',
      'roles.view',
      'audit.view',
    };
    for (final s in AdminSection.values) {
      expect(codes, contains(s.permission), reason: s.name);
    }
  });
}
