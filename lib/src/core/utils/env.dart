import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

/// Build/runtime settings, kept out of git.
///
/// Each value comes from `--dart-define` (or `--dart-define-from-file=web/dart_defines.json`)
/// first. Anything left empty is read at startup from `dart_defines.json`, served next to
/// `index.html` (`web/dart_defines.json` locally, which is gitignored), so a plain
/// `flutter run -d chrome` works too.
// ignore: avoid_classes_with_only_static_members
class Env {
  static const fileName = 'dart_defines.json';

  static String apiUrl = const String.fromEnvironment('API_URL');
  static String firebaseWebApiKey = const String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static String firebaseWebAppId = const String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
  );

  static bool get _complete =>
      apiUrl.isNotEmpty &&
      firebaseWebApiKey.isNotEmpty &&
      firebaseWebAppId.isNotEmpty;

  /// Fills the values not passed as dart-defines from [fileName]. A missing or
  /// malformed file is fine: the defaults (and the sign-in notice) take over.
  static Future<void> load() async {
    if (_complete) return;
    try {
      final response = await http
          // From the site root: Uri.base is the current page, e.g. /goals/<uuid>.
          .get(Uri.base.resolve('/$fileName'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;
      final json = jsonDecode(response.body);
      if (json is! Map) return;
      String read(String key, String current) =>
          current.isNotEmpty ? current : (json[key] as String? ?? '');
      apiUrl = read('API_URL', apiUrl);
      firebaseWebApiKey = read('FIREBASE_WEB_API_KEY', firebaseWebApiKey);
      firebaseWebAppId = read('FIREBASE_WEB_APP_ID', firebaseWebAppId);
    } catch (e) {
      // The dev server and nginx answer unknown paths with index.html.
      log('No usable $fileName: $e');
    }
  }
}
