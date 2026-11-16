import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color deepBlue = Color(0xFF1F4E79);
  static const Color corporateBlue = Color(0xFF5B9BD5);
  static const Color softGray = Color(0xFFF5F7FA);
  static const Color charcoal = Color(0xFF1F2937);
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);

  static ThemeData light() {
    final ColorScheme colors =
        ColorScheme.fromSeed(
          seedColor: deepBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: deepBlue,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFE8F1FA),
          onPrimaryContainer: deepBlue,
          secondary: corporateBlue,
          onSecondary: charcoal,
          secondaryContainer: const Color(0xFFE8F1FA),
          onSecondaryContainer: deepBlue,
          surface: Colors.white,
          onSurface: charcoal,
          onSurfaceVariant: const Color(0xFF526174),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: Colors.white,
          surfaceContainer: softGray,
          surfaceContainerHigh: const Color(0xFFEDF1F6),
          surfaceContainerHighest: const Color(0xFFE5EBF2),
          surfaceTint: Colors.transparent,
          outline: const Color(0xFF8998AA),
          outlineVariant: const Color(0xFFDCE3EB),
          error: error,
          onError: Colors.white,
          errorContainer: const Color(0xFFFDECEC),
          onErrorContainer: const Color(0xFF9B2020),
        );
    final ThemeData base = ThemeData(
      colorScheme: colors,
      useMaterial3: true,
      fontFamily: 'Geist',
    );
    return base.copyWith(
      scaffoldBackgroundColor: softGray,
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: deepBlue,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: deepBlue,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: deepBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: deepBlue,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: deepBlue, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(softGray),
        headingTextStyle: TextStyle(
          fontFamily: 'Geist',
          fontWeight: FontWeight.w600,
          color: deepBlue,
        ),
        dividerThickness: 1,
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: colors.outlineVariant,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: deepBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        visualDensity: VisualDensity.compact,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
