import 'package:flutter/material.dart';

// ============================================================
// APP COLORS - Beautiful Professional Color Palette
// ============================================================

class AppColors {
  // ============================================================
  // PRIMARY COLORS
  // ============================================================

  /// Primary Blue - Main brand color
  static const Color primaryBlue = Color(0xFF2A5CFF);

  /// Primary Purple - Secondary brand color
  static const Color primaryPurple = Color(0xFF7000FF);

  /// Primary Dark Blue - For dark mode backgrounds
  static const Color primaryDarkBlue = Color(0xFF0A0E27);

  // ============================================================
  // ACCENT COLORS
  // ============================================================

  /// Success Green - For correct answers, achievements
  static const Color successGreen = Color(0xFF4CAF50);

  /// Success Light Green - For gradients and highlights
  static const Color successLightGreen = Color(0xFF8BC34A);

  /// Warning Amber - For partial answers, warnings
  static const Color warningAmber = Color(0xFFFFB800);

  /// Warning Orange - For medium priority warnings
  static const Color warningOrange = Color(0xFFFF9800);

  /// Error Red - For incorrect answers, errors
  static const Color errorRed = Color(0xFFFF3B5C);

  /// Error Dark Red - For critical errors
  static const Color errorDarkRed = Color(0xFFF44336);

  /// Info Teal - For information, tips
  static const Color infoTeal = Color(0xFF00E096);

  /// Info Cyan - For secondary info
  static const Color infoCyan = Color(0xFF00BCD4);

  // ============================================================
  // NEUTRAL COLORS - LIGHT MODE
  // ============================================================

  /// Light Background - Main background in light mode
  static const Color lightBackground = Color(0xFFF5F7FF);

  /// Light Surface - Cards, dialogs in light mode
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light Surface Alt - Alternative surface color
  static const Color lightSurfaceAlt = Color(0xFFF8FAFF);

  /// Light Text Primary - Main text color in light mode
  static const Color lightTextPrimary = Color(0xFF0A0E27);

  /// Light Text Secondary - Secondary text color
  static const Color lightTextSecondary = Color(0xFF6B6B8A);

  /// Light Text Tertiary - Tertiary/muted text color
  static const Color lightTextTertiary = Color(0xFF9E9EB8);

  /// Light Border - Border color in light mode
  static const Color lightBorder = Color(0xFFE8ECFF);

  /// Light Divider - Divider color in light mode
  static const Color lightDivider = Color(0xFFEEF2FF);

  /// Light Hint - Hint text color
  static const Color lightHint = Color(0xFFB8C0E0);

  // ============================================================
  // NEUTRAL COLORS - DARK MODE
  // ============================================================

  /// Dark Background - Main background in dark mode
  static const Color darkBackground = Color(0xFF0A0E27);

  /// Dark Surface - Cards, dialogs in dark mode
  static const Color darkSurface = Color(0xFF1A1F3E);

  /// Dark Surface Alt - Alternative surface color
  static const Color darkSurfaceAlt = Color(0xFF131834);

  /// Dark Text Primary - Main text color in dark mode
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Dark Text Secondary - Secondary text color
  static const Color darkTextSecondary = Color(0xFF8E8EA8);

  /// Dark Text Tertiary - Tertiary/muted text color
  static const Color darkTextTertiary = Color(0xFF6A6A8A);

  /// Dark Border - Border color in dark mode
  static const Color darkBorder = Color(0xFF2A2F4A);

  /// Dark Divider - Divider color in dark mode
  static const Color darkDivider = Color(0xFF1F243E);

  /// Dark Hint - Hint text color
  static const Color darkHint = Color(0xFF5A5A7A);

  // ============================================================
  // GRADIENT COLORS
  // ============================================================

  /// Blue Gradient - For buttons and cards
  static const List<Color> blueGradient = [
    Color(0xFF2A5CFF),
    Color(0xFF4A7CFF),
  ];

  /// Purple Gradient - For examiner mode cards
  static const List<Color> purpleGradient = [
    Color(0xFF7000FF),
    Color(0xFF9C27B0),
  ];

  /// Green Gradient - For success elements
  static const List<Color> greenGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];

  /// Amber Gradient - For warning elements
  static const List<Color> amberGradient = [
    Color(0xFFFFB800),
    Color(0xFFFFD54F),
  ];

  /// Coral Gradient - For error elements
  static const List<Color> coralGradient = [
    Color(0xFFFF3B5C),
    Color(0xFFFF5722),
  ];

  /// Teal Gradient - For info elements
  static const List<Color> tealGradient = [
    Color(0xFF00E096),
    Color(0xFF4ADE80),
  ];

  /// Rainbow Gradient - For special achievements
  static const List<Color> rainbowGradient = [
    Color(0xFF2A5CFF),
    Color(0xFF7000FF),
    Color(0xFFFF3B5C),
    Color(0xFFFFB800),
    Color(0xFF00E096),
  ];

  // ============================================================
  // STATUS COLORS
  // ============================================================

  /// Excellent Score - 90% and above
  static const Color excellentScore = Color(0xFF4CAF50);

  /// Good Score - 75% to 89%
  static const Color goodScore = Color(0xFF2A5CFF);

  /// Average Score - 60% to 74%
  static const Color averageScore = Color(0xFFFFB800);

  /// Poor Score - 40% to 59%
  static const Color poorScore = Color(0xFFFF9800);

  /// Failing Score - Below 40%
  static const Color failingScore = Color(0xFFFF3B5C);

  // ============================================================
  // DIFFICULTY COLORS
  // ============================================================

  /// Easy Difficulty
  static const Color easyDifficulty = Color(0xFF4CAF50);

  /// Medium Difficulty
  static const Color mediumDifficulty = Color(0xFFFFB800);

  /// Hard Difficulty
  static const Color hardDifficulty = Color(0xFFFF3B5C);

  /// Expert Difficulty
  static const Color expertDifficulty = Color(0xFF7000FF);

  // ============================================================
  // CATEGORY COLORS
  // ============================================================

  /// Technical Category
  static const Color categoryTechnical = Color(0xFF2A5CFF);

  /// Database Category
  static const Color categoryDatabase = Color(0xFF00E096);

  /// API Category
  static const Color categoryAPI = Color(0xFF00BCD4);

  /// Security Category
  static const Color categorySecurity = Color(0xFFFF3B5C);

  /// Architecture Category
  static const Color categoryArchitecture = Color(0xFF7000FF);

  /// Frontend Category
  static const Color categoryFrontend = Color(0xFFFF9800);

  /// Backend Category
  static const Color categoryBackend = Color(0xFF9C27B0);

  /// General Category
  static const Color categoryGeneral = Color(0xFF9E9E9E);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get score color based on percentage
  static Color getScoreColor(double percentage) {
    if (percentage >= 90) return excellentScore;
    if (percentage >= 75) return goodScore;
    if (percentage >= 60) return averageScore;
    if (percentage >= 40) return poorScore;
    return failingScore;
  }

  /// Get difficulty color based on difficulty level
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return easyDifficulty;
      case 'medium':
        return mediumDifficulty;
      case 'hard':
        return hardDifficulty;
      case 'expert':
        return expertDifficulty;
      default:
        return mediumDifficulty;
    }
  }

  /// Get category color based on category name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return categoryTechnical;
      case 'database':
        return categoryDatabase;
      case 'api':
        return categoryAPI;
      case 'security':
        return categorySecurity;
      case 'architecture':
        return categoryArchitecture;
      case 'frontend':
        return categoryFrontend;
      case 'backend':
        return categoryBackend;
      default:
        return categoryGeneral;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
      case 'perfect':
      case 'correct':
        return successGreen;
      case 'good':
        return goodScore;
      case 'average':
        return averageScore;
      case 'poor':
        return poorScore;
      case 'failed':
      case 'incorrect':
        return failingScore;
      default:
        return lightTextSecondary;
    }
  }

  /// Get gradient based on score percentage
  static List<Color> getScoreGradient(double percentage) {
    if (percentage >= 90) return greenGradient;
    if (percentage >= 75) return blueGradient;
    if (percentage >= 60) return amberGradient;
    if (percentage >= 40) return coralGradient;
    return coralGradient;
  }
}

// ============================================================
// THEME COLOR UTILITIES
// ============================================================

class ThemeColors {
  /// Get background color based on theme mode
  static Color getBackgroundColor(bool isDark) {
    return isDark ? AppColors.darkBackground : AppColors.lightBackground;
  }

  /// Get surface color based on theme mode
  static Color getSurfaceColor(bool isDark) {
    return isDark ? AppColors.darkSurface : AppColors.lightSurface;
  }

  /// Get primary text color based on theme mode
  static Color getPrimaryTextColor(bool isDark) {
    return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  }

  /// Get secondary text color based on theme mode
  static Color getSecondaryTextColor(bool isDark) {
    return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  }

  /// Get border color based on theme mode
  static Color getBorderColor(bool isDark) {
    return isDark ? AppColors.darkBorder : AppColors.lightBorder;
  }

  /// Get divider color based on theme mode
  static Color getDividerColor(bool isDark) {
    return isDark ? AppColors.darkDivider : AppColors.lightDivider;
  }
}