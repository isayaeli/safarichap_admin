import 'package:firebase_auth/firebase_auth.dart';
import 'package:safarichap_admin/src/core/utils/firebase_auth_error.dart';
import 'package:safarichap_admin/src/core/utils/firebase_service.dart';
import '../models/result.dart';

/// Staff sign in with email + password (Firebase). Access itself is decided
/// by the API's role check (`GET /api/admin/me/`).
class AuthRepository {
  bool get isSignedIn =>
      isFirebaseReady && FirebaseAuth.instance.currentUser != null;

  /// Emits whenever someone signs in or out (including token expiry).
  Stream<bool> get signedInChanges => isFirebaseReady
      ? FirebaseAuth.instance
            .authStateChanges()
            .map((user) => user != null)
            .distinct()
      : const Stream.empty();

  String? get email =>
      isFirebaseReady ? FirebaseAuth.instance.currentUser?.email : null;

  Future<Result<void>> signInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return Success(null);
    } on FirebaseAuthException catch (e) {
      return Fail(FirebaseAuthErrorMapper.toMessage(e));
    }
  }

  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return Success(null);
    } on FirebaseAuthException catch (e) {
      return Fail(FirebaseAuthErrorMapper.toMessage(e));
    }
  }

  Future<void> signOut() async {
    if (isFirebaseReady) await FirebaseAuth.instance.signOut();
  }
}
