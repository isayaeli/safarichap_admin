import 'package:get/get.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // App-wide: the signed-in staff member with their permission codes (every
    // screen gates actions on them) and the selected dashboard section.
    Get.put(SessionController(sl(), sl()), permanent: true);
    Get.put(ShellController(sl()), permanent: true);
  }
}
