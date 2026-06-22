import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/theme/colors.dart';

// ============================================================
// APP TYPOGRAPHY - Beautiful Professional Font System
// ============================================================

class AppTypography {
  // ============================================================
  // FONT FAMILIES
  // ============================================================

  static const String primaryFontFamily = 'Poppins';
  static const String secondaryFontFamily = 'Inter';

  // ============================================================
  // HEADLINE STYLES
  // ============================================================

  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 96,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 60,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  // ============================================================
  // TITLE STYLES
  // ============================================================

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.3,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  // ============================================================
  // BODY STYLES
  // ============================================================

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );

  // ============================================================
  // LABEL STYLES
  // ============================================================

  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // ============================================================
  // SPECIAL STYLES
  // ============================================================

  static TextStyle get scoreDisplay => GoogleFonts.poppins(
    fontSize: 72,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1,
  );

  // FIXED: Removed GoogleFonts.droidSansMono, using standard TextStyle
  static TextStyle get timerText => const TextStyle(
    fontFamily: 'monospace',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    height: 1,
  );

  static TextStyle get questionText => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get answerText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.6,
  );

  static TextStyle get quoteText => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    height: 1,
  );

  // ============================================================
  // DASHBOARD SPECIFIC STYLES
  // ============================================================

  static TextStyle get welcomeText => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle get statNumber => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1,
  );

  static TextStyle get statLabel => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // ============================================================
  // REPORT SPECIFIC STYLES
  // ============================================================

  static TextStyle get reportTitle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle get scoreValue => GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1,
  );

  static TextStyle get categoryName => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  // ============================================================
  // HELPER METHODS
  // ============================================================

  static double getResponsiveFontSize(double baseSize, double screenWidth) {
    double scale = (screenWidth / 375).clamp(0.8, 1.2);
    return baseSize * scale;
  }

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

// ============================================================
// TEXT STYLE EXTENSIONS
// ============================================================

extension TextStyleExtension on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withLetterSpacing(double spacing) => copyWith(letterSpacing: spacing);
  TextStyle withHeight(double height) => copyWith(height: height);
}

// ============================================================
// PRE-DEFINED TEXT STYLES WITH COMMON USAGES
// ============================================================

class TextStyles {
  // Light Mode
  static TextStyle get lightDisplayLarge => AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary);
  static TextStyle get lightHeadlineLarge => AppTypography.headlineLarge.copyWith(color: AppColors.lightTextPrimary);
  static TextStyle get lightTitleLarge => AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary);
  static TextStyle get lightBodyLarge => AppTypography.bodyLarge.copyWith(color: AppColors.lightTextSecondary);
  static TextStyle get lightBodyMedium => AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary);
  static TextStyle get lightLabelLarge => AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary);

  // Dark Mode
  static TextStyle get darkDisplayLarge => AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get darkHeadlineLarge => AppTypography.headlineLarge.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get darkTitleLarge => AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary);
  static TextStyle get darkBodyLarge => AppTypography.bodyLarge.copyWith(color: AppColors.darkTextSecondary);
  static TextStyle get darkBodyMedium => AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary);
  static TextStyle get darkLabelLarge => AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary);

  // Theme-aware
  static TextStyle getDisplayLarge(bool isDark) => isDark ? darkDisplayLarge : lightDisplayLarge;
  static TextStyle getHeadlineLarge(bool isDark) => isDark ? darkHeadlineLarge : lightHeadlineLarge;
  static TextStyle getTitleLarge(bool isDark) => isDark ? darkTitleLarge : lightTitleLarge;
  static TextStyle getBodyLarge(bool isDark) => isDark ? darkBodyLarge : lightBodyLarge;
  static TextStyle getBodyMedium(bool isDark) => isDark ? darkBodyMedium : lightBodyMedium;
  static TextStyle getLabelLarge(bool isDark) => isDark ? darkLabelLarge : lightLabelLarge;
}

// ============================================================
// FONT WEIGHT CONSTANTS
// ============================================================

class FontWeights {
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}

// ============================================================
// FONT SIZES CONSTANTS
// ============================================================

class FontSizes {
  static const double displayLarge = 96;
  static const double displayMedium = 60;
  static const double displaySmall = 48;
  static const double headlineLarge = 40;
  static const double headlineMedium = 34;
  static const double headlineSmall = 28;
  static const double titleLarge = 24;
  static const double titleMedium = 20;
  static const double titleSmall = 18;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 16;
  static const double labelMedium = 14;
  static const double labelSmall = 12;
  static const double scoreDisplay = 72;
  static const double timerText = 48;
  static const double questionText = 22;
  static const double buttonText = 18;
}

// ============================================================
// LETTER SPACING CONSTANTS
// ============================================================

class LetterSpacing {
  static const double tight = -1.5;
  static const double compact = -0.5;
  static const double normal = 0;
  static const double wide = 0.5;
  static const double wider = 1;
  static const double widest = 2;
}