import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:safarichap_admin/firebase_options.dart';

/// Initialises Firebase (Auth only; the dashboard doesn't receive pushes).
/// Until the Web app's keys are configured this logs and continues, and the
/// sign-in screen explains what's missing.
Future<void> initFirebase() async {
  if (!DefaultFirebaseOptions.isConfigured) {
    log(
      'Firebase web keys missing: add web/dart_defines.json or pass --dart-define',
    );
    return;
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log('Firebase not configured yet: $e');
  }
}

bool get isFirebaseReady => Firebase.apps.isNotEmpty;
