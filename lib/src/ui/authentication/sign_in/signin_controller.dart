import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/auth_repository.dart';
import 'package:safarichap_admin/src/ui/onboarding/decision_tree.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';

class SignInController extends GetxController {
  final AuthRepository _authRepo;
  final SessionController _session;
  SignInController(this._authRepo, this._session);

  final isSigningIn = false.obs;
  final isSendingReset = false.obs;

  Future<void> signIn(String email, String password) async {
    await _authRepo.signInWithEmail(email, password).execute((result) async {
      isSigningIn.value = result is Loading;
      if (result is Success) {
        await _session.loadMe();
        Get.offAll(() => const DecisionTree());
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _authRepo.sendPasswordReset(email).execute((result) {
      isSendingReset.value = result is Loading;
      if (result is Success) {
        closeDialog();
        showSuccessSnack(
          "If @email is a staff account, a reset link is on its way.".trParams({
            'email': email,
          }),
        );
      } else if (result is Fail) {
        showErrorSnack(result.message);
      }
    });
  }
}
