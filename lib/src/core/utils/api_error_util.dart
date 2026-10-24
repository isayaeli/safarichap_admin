// lib/src/core/utils/api_error_util.dart

import 'dart:convert';
import 'package:get/get.dart';

class ApiErrorUtils {
  ApiErrorUtils._();

  /// Extracts a clean error message from any API error response body.
  /// Handles: {"error": "..."}, {"detail": "..."}, {"message": "..."},
  /// {"field": ["..."]}, plain strings.
  static String parse(dynamic body, {String? fallback}) {
    fallback ??= 'Something went wrong.'.tr;
    if (body == null) return fallback;

    if (body is String) {
      // Try to parse as JSON first in case it's a JSON string
      try {
        final decoded = jsonDecode(body);
        return parse(decoded, fallback: fallback);
      } catch (_) {
        return body.isEmpty ? fallback : body;
      }
    }

    if (body is Map) {
      final value =
          body['error'] ??
          body['detail'] ??
          body['message'] ??
          body['non_field_errors'] ??
          (body.values.isEmpty ? null : body.values.first);
      if (value == null) return fallback;
      if (value is List) {
        return value.isEmpty ? fallback : value.first.toString();
      }
      return value.toString();
    }

    if (body is List && body.isNotEmpty) {
      return body.first.toString();
    }

    return fallback;
  }
}
