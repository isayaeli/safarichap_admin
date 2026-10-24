import 'dart:ui';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../data/repositories/preferences_repository.dart';
import '../resources/translations/app_translations.dart';

/// App language. Strings use English as the translation key (`"Pay".tr`),
/// so English needs no map and anything untranslated falls back to it.
class LocaleManager {
  final PreferenceRepository _preferenceRepository;

  LocaleManager(this._preferenceRepository) {
    _applyIntl(locale);
  }

  static const english = Locale('en', 'US');
  static const swahili = Locale('sw', 'TZ');
  static const supported = [english, swahili];

  /// Saved choice, else the phone's language on first launch.
  Locale get locale {
    final code =
        _preferenceRepository.languageCode ??
        PlatformDispatcher.instance.locale.languageCode;
    return code == swahili.languageCode ? swahili : english;
  }

  bool get isSwahili => locale == swahili;

  Future<void> changeLocale(Locale locale) async {
    await _preferenceRepository.setLanguage(locale.languageCode);
    _applyIntl(locale);
    await Get.updateLocale(locale);
  }

  /// Dates (intl) and "x minutes ago" (timeago) follow the app language.
  void _applyIntl(Locale locale) {
    Intl.defaultLocale = locale.toLanguageTag().replaceAll('-', '_');
    timeago.setLocaleMessages(swahili.languageCode, SwahiliTimeagoMessages());
    timeago.setDefaultLocale(locale.languageCode);
  }
}
