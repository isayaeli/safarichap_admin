import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/safari_logo.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/ui/authentication/sign_in/signin_screen.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/shell/shell_screen.dart';

/// Picks the first screen: sign-in, "no access" (signed in but not staff), or
/// the dashboard once `GET /api/admin/me/` returns the staff profile.
class DecisionTree extends StatefulWidget {
  const DecisionTree({super.key});

  @override
  State<DecisionTree> createState() => _DecisionTreeState();
}

class _DecisionTreeState extends State<DecisionTree> {
  final SessionController _session = Get.find();

  @override
  void initState() {
    if (_session.isSignedIn) {
      _session.loadMe();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_session.isSignedIn) return const SignInScreen();

    return Obx(() {
      if (_session.me.value != null) return const ShellScreen();
      if (_session.noAccess.value) return const NoAccessScreen();
      if (_session.loadFailed.value) {
        return _RetryScreen(onRetry: _session.loadMe);
      }
      return const SplashScreen();
    });
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafariLogoPainter.tileColor,
      body: const Center(child: AdminWordmark(onDark: true)),
    );
  }
}

/// "SafariChap" with "Admin" underneath, for splash and sign-in.
class AdminWordmark extends StatelessWidget {
  final bool onDark;
  const AdminWordmark({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final textColor = onDark
        ? safariChapColors.onSecondaryColor!
        : Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SafariLogo(size: 72),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: "Safari"),
              TextSpan(
                text: "Chap",
                style: TextStyle(color: safariChapColors.primaryColor),
              ),
            ],
          ),
        ),
        Text(
          "Admin dashboard".tr,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find();
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  "No dashboard access".tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "@email isn't on the staff list, or the account was deactivated. Ask a Super Admin to invite you."
                      .trParams({'email': session.email ?? ''}),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: session.signOut,
                  child: Text("Sign out".tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _RetryScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text("We couldn't reach SafariChap.".tr),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text("Try again".tr)),
          ],
        ),
      ),
    );
  }
}
