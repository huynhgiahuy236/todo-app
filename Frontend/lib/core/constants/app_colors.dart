import 'package:flutter/material.dart';

class AppColors {
  // Apple iPhone Monochrome Palette
  static const Color primary = Color(0xFF000000); // Apple Jet Black
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1C1C1E);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFE5E5EA);
  static const Color onPrimaryFixed = Color(0xFF000000);
  static const Color onPrimaryFixedVariant = Color(0xFF1C1C1E);

  // Secondary
  static const Color secondary = Color(0xFF2C2C2E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF3A3A3C);
  static const Color onSecondaryContainer = Color(0xFFFFFFFF);
  static const Color secondaryFixed = Color(0xFFE5E5EA);
  static const Color onSecondaryFixedVariant = Color(0xFF2C2C2E);

  // Tertiary
  static const Color tertiary = Color(0xFF48484A);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF636366);
  static const Color tertiaryFixed = Color(0xFFE5E5EA);
  static const Color tertiaryFixedDim = Color(0xFF8E8E93);

  // Canvas & Surfaces (Apple iOS Light)
  static const Color background = Color(0xFFF2F2F7); // iOS Grouped Background
  static const Color surface = Color(0xFFF2F2F7);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFE5E5EA);
  static const Color surfaceContainer = Color(0xFFD1D1D6);
  static const Color surfaceContainerHigh = Color(0xFFC7C7CC);
  static const Color surfaceContainerHighest = Color(0xFFAEAEB2);

  // Text & Icons (Apple System Text)
  static const Color onSurface = Color(0xFF000000);
  static const Color onSurfaceVariant = Color(0xFF3C3C43);
  static const Color outline = Color(0xFF8E8E93); // Apple System Gray
  static const Color outlineVariant = Color(0xFFC7C7CC);
  static const Color divider = Color(0xFFE5E5EA);

  // Status & Priority
  static const Color error = Color(0xFFFF3B30); // Apple System Red
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFE5E5);
  static const Color onErrorContainer = Color(0xFFD70015);
  static const Color success = Color(0xFF34C759); // Apple System Green
  static const Color warning = Color(0xFFFF9500); // Apple System Orange

  // Category Colors (Vibrant tones for colorful schedule cards)
  static const Color catStudy = Color(0xFF3B4371); // Night Indigo
  static const Color catWork = Color(0xFF10B981); // Emerald Mint
  static const Color catPersonal = Color(0xFFF59E0B); // Amber Sun
  static const Color catImportant = Color(0xFFE11D48); // Rose Crimson
  static const Color catMeeting = Color(0xFFF97316); // Sunset Coral
  static const Color catOther = Color(0xFF6366F1); // Royal Indigo

  // Color Swatches
  static const List<Color> scheduleColorSwatches = [
    Color(0xFF3B4371), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFF97316), // Coral
    Color(0xFFE11D48), // Rose
    Color(0xFF6366F1), // Royal Indigo
  ];

  static Color getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'study':
      case 'học tập':
        return catStudy;
      case 'work':
      case 'công việc':
      case 'project':
        return catWork;
      case 'personal':
      case 'cá nhân':
        return catPersonal;
      case 'meeting':
      case 'họp':
        return catMeeting;
      case 'important':
      case 'deadline':
      case 'quan trọng':
        return catImportant;
      default:
        return catOther;
    }
  }

  // Apple Subtle Box Shadows
  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? const Color(0x60000000) : const Color(0x0A000000),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: isDark ? const Color(0x40000000) : const Color(0x04000000),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> sheetShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? const Color(0x80000000) : const Color(0x18000000),
        blurRadius: 28,
        spreadRadius: 0,
        offset: const Offset(0, -6),
      ),
    ];
  }
}

extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get isDarkMode => isDark;
  Color get surfaceCard => isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
  Color get scaffoldBg => isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get textPrimary => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color get textSecondary => isDark ? const Color(0xFF8E8E93) : const Color(0xFF636366);
  Color get textMuted => isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93);
  Color get containerLow => isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF4F4F6);
  Color get borderDivider => isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
}

