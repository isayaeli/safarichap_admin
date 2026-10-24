import 'package:flutter/foundation.dart';

import 'env.dart';

// ignore: avoid_classes_with_only_static_members
class AppConfig {
  static const _prod = "https://api.safarichap.co.tz";

  /// The Django dev server (`docker compose -f docker-compose.dev.yaml up`).
  static const _dev = "http://localhost:8000";

  static String baseUrl() {
    // API_URL from a dart-define or web/dart_defines.json (see Env).
    if (Env.apiUrl.isNotEmpty) return Env.apiUrl;
    return kDebugMode ? _dev : _prod;
  }

  /// Rows per page in every table.
  static const pageSize = 25;

  /// How long search waits after the last keystroke before querying.
  static const searchDebounce = Duration(milliseconds: 400);
}
