import 'dart:async';
import 'dart:developer';
import 'package:chopper/chopper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart' as get_x;
import 'package:http/http.dart' as http;
import 'package:safarichap_admin/src/data/services/access/access_service.dart';
import 'package:safarichap_admin/src/data/services/bookings/bookings_service.dart';
import 'package:safarichap_admin/src/data/services/catalogue/catalogue_service.dart';
import 'package:safarichap_admin/src/data/services/customers/customers_service.dart';
import 'package:safarichap_admin/src/data/services/goals/goals_service.dart';
import 'package:safarichap_admin/src/data/services/payments/payments_service.dart';
import 'package:safarichap_admin/src/data/services/system/system_service.dart';
import 'package:safarichap_admin/src/ui/authentication/sign_in/signin_screen.dart';
import '../core/utils/app_config.dart';

/// Sends the Firebase ID token and retries once with a fresh token on 401.
/// A 403 means the staff member lacks the permission, so it is returned as is.
class AdminRequestInterceptor implements Interceptor {
  Future<String> _token({bool forceRefresh = false}) async {
    if (Firebase.apps.isEmpty) return "";
    return await FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh) ??
        "";
  }

  @override
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    var token = await _token();
    var request = applyHeader(chain.request, 'Authorization', 'Bearer $token');

    var response = await chain.proceed(request);

    if (response.statusCode == 401) {
      final user = Firebase.apps.isEmpty
          ? null
          : FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (get_x.Get.currentRoute != '/SignInScreen') {
          get_x.Get.offAll(() => const SignInScreen());
        }
        return response;
      }

      try {
        token = await _token(forceRefresh: true);
        final newRequest = applyHeader(
          chain.request,
          'Authorization',
          'Bearer $token',
        );
        response = await chain.proceed(newRequest);
      } catch (e) {
        log('Failed to refresh token: $e');
        return response;
      }
    }

    return response;
  }
}

class AdminClient {
  AdminClient({http.Client? client})
    : _chopper = ChopperClient(
        baseUrl: Uri.parse(AppConfig.baseUrl()),
        client: client ?? http.Client(),
        errorConverter: const JsonConverter(),
        converter: const JsonConverter(),
        interceptors: [
          AdminRequestInterceptor(),
          HttpLoggingInterceptor(level: Level.basic),
        ],
      );

  final ChopperClient _chopper;

  AccessService accessService() => AccessService.create(_chopper);
  CustomersService customersService() => CustomersService.create(_chopper);
  GoalsService goalsService() => GoalsService.create(_chopper);
  PaymentsService paymentsService() => PaymentsService.create(_chopper);
  BookingsService bookingsService() => BookingsService.create(_chopper);
  CatalogueService catalogueService() => CatalogueService.create(_chopper);
  SystemService systemService() => SystemService.create(_chopper);
}
