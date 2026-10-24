import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirebaseAuthErrorMapper {
  FirebaseAuthErrorMapper._();

  static String toMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return "That phone number doesn't look right.".tr;
      case 'invalid-verification-code':
        return "The code you entered is incorrect.".tr;
      case 'session-expired':
      case 'code-expired':
        return "The code has expired. Request a new one.".tr;
      case 'too-many-requests':
        return "Too many attempts. Please wait a moment and try again.".tr;
      case 'user-disabled':
        return "This account has been disabled.".tr;
      case 'invalid-email':
        return "Enter a valid email address.".tr;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "Email or password is incorrect.".tr;
      case 'email-already-in-use':
        return "An account already exists with this email. Sign in instead.".tr;
      case 'weak-password':
        return "Choose a stronger password (at least 6 characters).".tr;
      case 'network-request-failed':
        return "No internet connection. Check your network and try again.".tr;
      case 'account-exists-with-different-credential':
        return "This email is linked to a different sign-in method.".tr;
      default:
        return e.message ?? "Authentication failed. Please try again.".tr;
    }
  }
}
