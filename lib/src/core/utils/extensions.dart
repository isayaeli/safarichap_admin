import 'dart:developer';
import 'package:chopper/chopper.dart';
import 'package:get/get.dart' hide Response;

import '../../data/models/result.dart';
import 'api_error_util.dart';

extension FutureExtensions<T> on Future<Result<T>> {
  Future<void> execute(Function(Result result) f) async {
    f(Loading());
    try {
      final response = await this;
      if (response is Fail && (response as Fail).code == 502) {
        f(Fail("502 Bad Gateway", code: 502));
      } else {
        f(response);
      }
    } catch (ex) {
      f(Fail(ex.toString()));
    }
  }
}

extension ResponseExtensions on Response {
  String get errorMessage => _getError();

  String _getError() {
    if (error == null) return "Connection Interrupted, try again".tr;
    return ApiErrorUtils.parse(error);
  }
}

extension DateOnly on DateTime {
  /// "2027-01-15" — the format the API uses for date-only fields.
  String toApiDate() => toIso8601String().substring(0, 10);

  DateTime get dateOnly => DateTime(year, month, day);
}

extension ResponseResult on Response {
  /// Success with [map] applied to the body, or Fail with the API's message.
  Result<T> toResult<T>(T Function(dynamic body) map) {
    // `this.` matters: a bare `body` resolves to chopper's top-level `@body`
    // annotation constant before the extension's receiver.
    if (isSuccessful) return Success<T>(map(this.body));
    log('Error : ${base.statusCode} ${base.request?.url}');
    return Fail<T>(errorMessage, code: base.statusCode);
  }
}

/// Drops null/empty values so they aren't sent as `?status=`.
Map<String, dynamic> cleanQuery(Map<String, dynamic> query) => {
  for (final e in query.entries)
    if (e.value != null && e.value.toString().isNotEmpty)
      e.key: e.value.toString(),
};
