import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/progressed_button.dart';
import 'package:safarichap_admin/src/core/utils/firebase_service.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/startup_screens.dart';
import 'package:safarichap_admin/src/core/utils/navigation.dart';
import 'package:safarichap_admin/src/core/components/busy_button.dart';

import 'signin_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _controller = Get.put(SignInController(sl(), Get.find()));
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    _controller.signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AdminWordmark(),
                          const SizedBox(height: 28),
                          if (!isFirebaseReady) ...[
                            _FirebaseMissing(),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: "Work email".tr,
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? "Enter your email".tr
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: "Password".tr,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? "Enter your password".tr
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isFirebaseReady ? _showReset : null,
                              child: Text("Forgot password?".tr),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => ProgressedButton(
                              text: "Sign in".tr,
                              isLoading: _controller.isSigningIn.value,
                              isEnabled: isFirebaseReady,
                              onClick: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReset() {
    final email = TextEditingController(text: _email.text);
    Get.dialog(
      AlertDialog(
        title: Text("Reset password".tr),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Work email".tr),
          ),
        ),
        actions: [
          TextButton(onPressed: () => closeDialog(), child: Text("Cancel".tr)),
          Obx(
            () => BusyButton(
              busy: _controller.isSendingReset.value,
              onPressed: () => _controller.sendPasswordReset(email.text),
              label: "Send link".tr,
            ),
          ),
        ],
      ),
    );
  }
}

class _FirebaseMissing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Firebase isn't configured for the web yet. Copy dart_defines.example.json to web/dart_defines.json and fill in FIREBASE_WEB_API_KEY and FIREBASE_WEB_APP_ID."
            .tr,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
