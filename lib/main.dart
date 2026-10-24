import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:safarichap_admin/src/safarichap_admin.dart';
import 'src/core/utils/firebase_service.dart';
import 'src/st/st.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(); // month names in English and Kiswahili
  await initFirebase();
  initLogging();
  await initGetIt();
  runApp(const SafariChapAdmin());
}
