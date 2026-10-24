import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';

/// Shows [child] only when the staff member has [code]. The API still
/// enforces it; this just hides buttons that would fail with 403.
class PermissionGate extends StatelessWidget {
  final String code;
  final Widget child;
  final Widget? otherwise;

  const PermissionGate({
    super.key,
    required this.code,
    required this.child,
    this.otherwise,
  });

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find();
    return session.can(code) ? child : (otherwise ?? const SizedBox.shrink());
  }
}

bool can(String code) => Get.find<SessionController>().can(code);
