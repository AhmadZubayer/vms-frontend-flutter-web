import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppTheme {
  const AppTheme._();

  static const Color deepBlue = Color(0xFF1F4E79);
  static const Color corporateBlue = Color(0xFF5B9BD5);
  static const Color softGray = Color(0xFFF5F7FA);
  static const Color charcoal = Color(0xFF1F2937);
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color white = Color(0xFFFFFFFF);

  static final FThemeData light = _light();

  static FThemeData _light() {
    final colors = FTheme.neutral.light.touch.colors.copyWith(
      background: softGray,
      foreground: charcoal,
      primary: deepBlue,
      primaryForeground: white,
      secondary: corporateBlue,
      secondaryForeground: charcoal,
      muted: const Color(0xFFEDF1F6),
      mutedForeground: const Color(0xFF526174),
      card: white,
      border: const Color(0xFFDCE3EB),
      destructive: error,
      destructiveForeground: white,
      error: error,
      errorForeground: white,
    );
    final typeface = FTypeface.inherit(
      colors: colors,
      touch: true,
      fontFamily: 'Geist',
    );
    final theme = FThemeData(
      colors: colors,
      touch: true,
      typography: FTypography(
        display: FTypeface.inherit(
          colors: colors.copyWith(foreground: deepBlue),
          touch: true,
          fontFamily: 'Geist',
        ),
        body: typeface,
      ),
    );
    return theme.copyWith(
      scaffoldStyle: theme.scaffoldStyle.copyWith(
        sidebarBackgroundColor: white,
      ),
      sidebarStyle: theme.sidebarStyle.copyWith(
        decoration: .value(
          BoxDecoration(
            color: white,
            border: Border(right: BorderSide(color: colors.border)),
          ),
        ),
      ),
      dividerStyles: FDividerStyles.inherit(
        colors: colors.copyWith(secondary: colors.border),
        style: theme.style,
      ),
    );
  }
}
