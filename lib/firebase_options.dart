// The dashboard signs in to the same Firebase project as the mobile app
// ("safarichap") as the Web app "safarichap_admin".
//
// The API key and app id are NOT in source: they come from `Env`
// (dart-defines or `web/dart_defines.json`, both outside git). Don't re-run
// `flutterfire configure` without removing the keys it writes back here.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:safarichap_admin/src/core/utils/env.dart';

class DefaultFirebaseOptions {
  static bool get isConfigured =>
      Env.firebaseWebApiKey.isNotEmpty && Env.firebaseWebAppId.isNotEmpty;

  static FirebaseOptions get currentPlatform => web;

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: Env.firebaseWebApiKey,
    appId: Env.firebaseWebAppId,
    messagingSenderId: '821444152681',
    projectId: 'safarichap',
    authDomain: 'safarichap.firebaseapp.com',
    storageBucket: 'safarichap.firebasestorage.app',
  );
}
