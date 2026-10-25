import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/safari_logo.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';

/// Shown while `GET /api/admin/me/` loads after sign-in; offers a retry if it fails.
/// The router leaves this page once the staff profile arrives.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find();
    return Obx(
      () => session.loadFailed.value
          ? _RetryScreen(onRetry: session.loadMe)
          : const SplashScreen(),
    );
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
