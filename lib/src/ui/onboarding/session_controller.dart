import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/models/staff/staff.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';
import 'package:safarichap_admin/src/data/repositories/auth_repository.dart';

/// The signed-in staff member and their permission codes. The API enforces
/// every permission; [can] only decides what the dashboard shows.
///
/// The router redirects on [routerRefresh], which fires on sign-in/out and
/// whenever the staff profile loads or fails.
class SessionController extends GetxController {
  final AuthRepository _authRepository;
  final AccessRepository _accessRepository;
  SessionController(this._authRepository, this._accessRepository);

  final me = Rxn<AdminMe>();
  final isLoading = false.obs;

  /// Signed in with Firebase but the API says this isn't an active staff member.
  final noAccess = false.obs;
  final loadFailed = false.obs;

  final routerRefresh = _RouterRefresh();
  StreamSubscription<bool>? _authChanges;

  bool get isSignedIn => _authRepository.isSignedIn;
  String? get email => _authRepository.email;

  Set<String> get _codes => me.value?.permissions.toSet() ?? const {};

  bool can(String code) => _codes.contains(code);

  bool canAny(Iterable<String> codes) => codes.any(_codes.contains);

  @override
  void onInit() {
    everAll([me, noAccess, loadFailed], (_) => routerRefresh.notify());
    _authChanges = _authRepository.signedInChanges.listen((signedIn) {
      if (signedIn) {
        if (me.value == null && !isLoading.value) loadMe();
      } else {
        _clear();
      }
      routerRefresh.notify();
    });
    if (isSignedIn) loadMe();
    super.onInit();
  }

  @override
  void onClose() {
    _authChanges?.cancel();
    routerRefresh.dispose();
    super.onClose();
  }

  Future<void> loadMe() async {
    loadFailed.value = false;
    noAccess.value = false;
    await _accessRepository.retrieveMe().execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        me.value = result.data as AdminMe;
      } else if (result is Fail) {
        if (result.code == 403) {
          noAccess.value = true;
        } else {
          loadFailed.value = true;
        }
      }
    });
  }

  /// The router sends the user to sign-in once [me] clears.
  Future<void> signOut() async {
    await _authRepository.signOut();
    _clear();
  }

  void _clear() {
    me.value = null;
    noAccess.value = false;
    loadFailed.value = false;
  }
}

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}
