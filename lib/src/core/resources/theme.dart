import 'package:flutter/material.dart';
import 'colors.dart';

/// App theme built from [safariChapColors]. Light mode uses the brand palette
/// as-is; dark mode keeps the gold/olive accents on dark surfaces.
ThemeData buildSafariTheme({required bool isDark}) {
  final c = safariChapColors;

  final scheme = isDark
      ? ColorScheme.fromSeed(
          seedColor: c.primaryColor!,
          brightness: Brightness.dark,
        ).copyWith(
          primary: c.primaryColor,
          onPrimary: c.onPrimaryColor,
          secondary: c.tertiaryColor,
          onSecondary: c.textPrimaryColor,
          tertiary: c.tertiaryColor,
          onTertiary: c.textPrimaryColor,
          outline: c.borderColor!.withValues(alpha: 0.5),
          outlineVariant: c.borderColor!.withValues(alpha: 0.3),
        )
      : ColorScheme.fromSeed(
          seedColor: c.primaryColor!,
          brightness: Brightness.light,
        ).copyWith(
          primary: c.primaryColor,
          onPrimary: c.onPrimaryColor,
          secondary: c.secondaryColor,
          onSecondary: c.onSecondaryColor,
          secondaryContainer: c.tertiaryColor,
          onSecondaryContainer: c.textPrimaryColor,
          tertiary: c.tertiaryColor,
          onTertiary: c.textPrimaryColor,
          surface: c.surfaceColor,
          onSurface: c.textPrimaryColor,
          onSurfaceVariant: c.textSecondaryColor,
          surfaceContainerLowest: c.surfaceColor,
          surfaceContainerLow: c.surfaceColor,
          surfaceContainer: c.backgroundColor,
          surfaceContainerHigh: c.backgroundColor,
          surfaceContainerHighest: c.backgroundColor,
          outline: c.borderColor,
          outlineVariant: c.borderColor,
        );

  final pressed = c.tertiaryPressedColor!.withValues(alpha: 0.18);

  return ThemeData(
    useMaterial3: true,
    fontFamily: "Poppins",
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark ? null : c.backgroundColor,
    cardColor: isDark ? null : c.surfaceColor,
    dividerColor: scheme.outlineVariant,
    splashColor: pressed,
    highlightColor: pressed,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? null : c.backgroundColor,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? null : c.surfaceColor,
      selectedItemColor: isDark ? c.primaryColor : c.secondaryColor,
      unselectedItemColor: scheme.onSurfaceVariant,
    ),
    chipTheme: ChipThemeData(
      selectedColor: c.tertiaryColor,
      side: BorderSide(color: scheme.outline),
      checkmarkColor: c.textPrimaryColor,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.tertiaryColor : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? c.textPrimaryColor : null,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: isDark ? c.primaryColor : c.secondaryColor,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: c.primaryColor,
      dividerColor: scheme.outlineVariant,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primaryColor),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: isDark ? null : c.surfaceColor,
      indicatorColor: c.primaryColor!.withValues(alpha: 0.25),
      selectedIconTheme: IconThemeData(
        color: isDark ? c.primaryColor : c.secondaryColor,
      ),
      selectedLabelTextStyle: TextStyle(
        fontFamily: "Poppins",
        fontWeight: FontWeight.w600,
        color: isDark ? c.primaryColor : c.secondaryColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? null : c.surfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: TextStyle(
        fontFamily: "Poppins",
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
      ),
      dataTextStyle: TextStyle(
        fontFamily: "Poppins",
        fontSize: 13,
        color: scheme.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c.primaryColor!, width: 2),
      ),
    ),
  );
}
