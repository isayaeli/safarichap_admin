import 'dart:async';
import 'package:flutter/foundation.dart';

import 'app_config.dart';

class Debouncer {
  Debouncer({this.delay = AppConfig.searchDebounce});

  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
