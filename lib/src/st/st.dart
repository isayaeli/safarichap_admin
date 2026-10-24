import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:safarichap_admin/src/data/repositories/access_repository.dart';
import 'package:safarichap_admin/src/data/repositories/booking_repository.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/data/repositories/customer_repository.dart';
import 'package:safarichap_admin/src/data/repositories/goal_repository.dart';
import 'package:safarichap_admin/src/data/repositories/payment_repository.dart';
import 'package:safarichap_admin/src/data/repositories/preferences_repository.dart';
import 'package:safarichap_admin/src/data/repositories/system_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/locale_manager.dart';
import '../core/utils/theme_manager.dart';
import '../data/admin_client.dart';
import '../data/repositories/auth_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> initGetIt() async {
  final sharePrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<PreferenceRepository>(
    () => PreferenceRepository(sharePrefs),
  );
  sl.registerLazySingleton<AdminClient>(() => AdminClient());

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<AccessRepository>(() => AccessRepository(sl()));
  sl.registerLazySingleton<CustomerRepository>(() => CustomerRepository(sl()));
  sl.registerLazySingleton<GoalRepository>(() => GoalRepository(sl()));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepository(sl()));
  sl.registerLazySingleton<BookingRepository>(() => BookingRepository(sl()));
  sl.registerLazySingleton<CatalogueRepository>(
    () => CatalogueRepository(sl()),
  );
  sl.registerLazySingleton<SystemRepository>(() => SystemRepository(sl()));

  sl.registerLazySingleton<ThemeManager>(() => ThemeManager(sl()));
  sl.registerLazySingleton<LocaleManager>(() => LocaleManager(sl()));
}

void initLogging() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    log('${record.level.name}: ${record.time}: ${record.message}');
  });
}
