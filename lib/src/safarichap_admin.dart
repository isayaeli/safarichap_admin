import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/route_manager.dart';
import 'package:safarichap_admin/src/bindings/initial_binding.dart';
import 'package:safarichap_admin/src/core/resources/theme.dart';
import 'package:safarichap_admin/src/core/resources/translations/app_translations.dart';
import 'package:safarichap_admin/src/core/utils/locale_manager.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/decision_tree.dart';
import 'core/utils/theme_manager.dart';

class SafariChapAdmin extends StatefulWidget {
  const SafariChapAdmin({super.key});

  @override
  State<SafariChapAdmin> createState() => _SafariChapAdminState();
}

class _SafariChapAdminState extends State<SafariChapAdmin> {
  final ThemeManager _themeManager = sl();
  final LocaleManager _localeManager = sl();

  @override
  void initState() {
    _themeManager.addListener(_themeListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitialBinding(),
      navigatorKey: Get.key,
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
      home: const DecisionTree(),
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
