import 'package:flutter/material.dart';

class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF005AB6); // Vibrant Ocean Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0472E3);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);
  static const Color primaryFixed = Color(0xFFD7E3FF);
  static const Color onPrimaryFixed = Color(0xFF001B3F);
  static const Color onPrimaryFixedVariant = Color(0xFF00458F);

  // Secondary
  static const Color secondary = Color(0xFF195BB9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF689DFE);
  static const Color onSecondaryContainer = Color(0xFF003372);
  static const Color secondaryFixed = Color(0xFFD8E2FF);
  static const Color onSecondaryFixedVariant = Color(0xFF004493);

  // Tertiary
  static const Color tertiary = Color(0xFF006387);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF007DA9);
  static const Color tertiaryFixed = Color(0xFFC4E7FF);
  static const Color tertiaryFixedDim = Color(0xFF7BD0FF);

  // Canvas & Surfaces (Light)
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Text & Icons
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF414753);
  static const Color outline = Color(0xFF717785);
  static const Color outlineVariant = Color(0xFFC1C6D6);
  static const Color divider = Color(0xFFE2E8F0);

  // Status & Priority
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Category Colors
  static const Color catStudy = Color(0xFF006387); // Deep Cyan/Emerald
  static const Color catWork = Color(0xFF005AB6); // Ocean Blue
  static const Color catPersonal = Color(0xFF8B5CF6); // Purple
  static const Color catImportant = Color(0xFFF59E0B); // Amber/Orange
  static const Color catMeeting = Color(0xFF007DA9); // Sky Blue
  static const Color catOther = Color(0xFF717785); // Slate

  // Color Swatches available for Schedule Selection
  static const List<Color> scheduleColorSwatches = [
    Color(0xFF005AB6), // Ocean Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Coral Red
    Color(0xFF007DA9), // Sky Blue
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

  // Common modern box shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.02),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get sheetShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.08),
          blurRadius: 25,
          offset: const Offset(0, -5),
        ),
      ];
}
