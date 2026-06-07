import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF275300);
  static const primaryContainer = Color(0xFF3B6D11);
  static const primaryFixed = Color(0xFFB8F389);
  static const primaryFixedDim = Color(0xFF9DD770);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFB2ED83);
  static const onPrimaryFixed = Color(0xFF0C2000);

  static const secondary = Color(0xFF805533);
  static const secondaryContainer = Color(0xFFFDC39A);
  static const secondaryFixed = Color(0xFFFFDCC5);
  static const secondaryFixedDim = Color(0xFFF4BB92);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF794E2E);
  static const onSecondaryFixed = Color(0xFF301400);

  static const tertiary = Color(0xFF4C4841);
  static const tertiaryContainer = Color(0xFF646059);
  static const tertiaryFixed = Color(0xFFE8E2D8);
  static const tertiaryFixedDim = Color(0xFFCCC6BC);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFFE1DBD1);
  static const onTertiaryFixed = Color(0xFF1E1B16);

  static const surface = Color(0xFFEFFFDB);
  static const surfaceBright = Color(0xFFEFFFDB);
  static const surfaceDim = Color(0xFFC8E3AE);
  static const surfaceVariant = Color(0xFFD0EBB6);
  static const surfaceContainer = Color(0xFFDBF7C1);
  static const surfaceContainerLow = Color(0xFFE1FCC6);
  static const surfaceContainerHigh = Color(0xFFD6F1BB);
  static const surfaceContainerHighest = Color(0xFFD0EBB6);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF0D2001);
  static const onSurfaceVariant = Color(0xFF42493B);

  static const background = Color(0xFFEFFFDB);
  static const onBackground = Color(0xFF0D2001);

  static const outline = Color(0xFF727969);
  static const outlineVariant = Color(0xFFC2C9B7);

  static const inverseSurface = Color(0xFF213611);
  static const inverseOnSurface = Color(0xFFDEFAC3);
  static const inversePrimary = Color(0xFF9DD770);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onError = Color(0xFFFFFFFF);
  static const onErrorContainer = Color(0xFF93000A);

  static const surfaceTint = Color(0xFF386A0E);
  static const cream = Color(0xFFFFF8EE);
  static const amber = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, color: AppColors.onSurface),
          displayMedium: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
          displaySmall: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
          headlineLarge: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
          headlineMedium: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600, color: AppColors.onSurface),
          headlineSmall: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600, color: AppColors.onSurface),
          titleLarge: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
          titleMedium: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600, color: AppColors.onSurface),
          titleSmall: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600, color: AppColors.onSurface),
          bodyLarge: GoogleFonts.beVietnamPro(color: AppColors.onSurface),
          bodyMedium: GoogleFonts.beVietnamPro(color: AppColors.onSurface),
          bodySmall: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
          labelLarge: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
          labelMedium: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600, color: AppColors.onSurface),
          labelSmall: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
          elevation: 0,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.primary,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
      );
}
