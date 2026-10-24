import 'dart:ui';

class SafariChapColors {
  Color? primaryColor;
  Color? secondaryColor;
  Color? tertiaryColor;
  Color? tertiaryPressedColor;
  Color? backgroundColor;
  Color? surfaceColor;
  Color? borderColor;
  Color? textPrimaryColor;
  Color? textSecondaryColor;
  Color? onPrimaryColor;
  Color? onSecondaryColor;
  Color? priceColor;
  Color? successColor;
  Color? warningColor;
  SafariChapColors({
    this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.tertiaryPressedColor,
    this.backgroundColor,
    this.surfaceColor,
    this.borderColor,
    this.textPrimaryColor,
    this.textSecondaryColor,
    this.onPrimaryColor,
    this.onSecondaryColor,
    this.priceColor,
    this.successColor,
    this.warningColor,
  });
}

SafariChapColors safariChapColors = SafariChapColors(
  primaryColor: const Color(0xFFB28247), // gold
  secondaryColor: const Color(0xFF2A4B41), // deep olive
  tertiaryColor: const Color(0xFF9D9667), // tags & secondary chips
  tertiaryPressedColor: const Color(0xFF6A6835), // hover / pressed olive
  backgroundColor: const Color(0xFFF1EAD7),
  surfaceColor: const Color(0xFFF5F1E1),
  borderColor: const Color(0xFFC9BC9A),
  textPrimaryColor: const Color(0xFF121212),
  textSecondaryColor: const Color(0xFF5E5446),
  onPrimaryColor: const Color(0xFF121212), // text on gold
  onSecondaryColor: const Color(0xFFF1EAD7), // text on olive
  // Prices are text: olive reads better on the cream background than gold.
  priceColor: const Color(0xFF2A4B41),
  successColor: const Color(0xFF2E7D32),
  warningColor: const Color(0xFFE6A23C),
);
