import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/bindings/initial_binding.dart';
import 'package:safarichap_admin/src/core/resources/theme.dart';
import 'package:safarichap_admin/src/core/resources/translations/app_translations.dart';
import 'package:safarichap_admin/src/core/utils/locale_manager.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:go_router/go_router.dart';
import 'package:safarichap_admin/src/routes/app_router.dart';
import 'core/utils/theme_manager.dart';

class SafariChapAdmin extends StatefulWidget {
  const SafariChapAdmin({super.key});

  @override
  State<SafariChapAdmin> createState() => _SafariChapAdminState();
}

class _SafariChapAdminState extends State<SafariChapAdmin> {
  final ThemeManager _themeManager = sl();
  final LocaleManager _localeManager = sl();

  late final GoRouter _router;

  @override
  void initState() {
    // The router reads the session, so the app-wide controllers come first.
    InitialBinding().dependencies();
    _router = createAppRouter(Get.find());
    _themeManager.addListener(_themeListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      title: "SafariChap Admin",
      translations: AppTranslations(),
      locale: _localeManager.locale,
      fallbackLocale: LocaleManager.english,
      supportedLocales: LocaleManager.supported,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: buildSafariTheme(isDark: _themeManager.isDark),
    );
  }

  void _themeListener() {
    if (mounted) {
      setState(() {}); // This will triggered app recomposition.
    }
  }

  @override
  void dispose() {
    _themeManager.removeListener(_themeListener);
    super.dispose();
  }
}
