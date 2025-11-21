import 'package:flutter/material.dart';

/// Theme-aware color helpers
/// These replace the old hardcoded color constants with dynamic theme-aware colors
class AppColors {
  // Primary colors
  static Color primaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color secondaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  // Background colors
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color cardColor(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  // Text colors
  static Color primaryTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color secondaryTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  // Border colors
  static Color borderColor(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  // Accent colors
  static Color accentColor(BuildContext context) => const Color(0xFFE0E7FF);

  // Status colors
  static Color successColor(BuildContext context) => const Color(0xFF10B981);
  static Color warningColor(BuildContext context) => const Color(0xFFF97316);
  static Color errorColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}

// Backward compatibility: These constants are deprecated
// Use AppColors.xxxColor(context) instead
const Color kPrimaryColor = Color(0xFF196EB0);
const Color kBackgroundColor = Color(0xFFF8FAFC);
const Color kCardColor = Colors.white;
const Color kPrimaryTextColor = Color(0xFF1E293B);
const Color kSecondaryTextColor = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kAccentColor = Color(0xFFE0E7FF);
const Color kSuccessColor = Color(0xFF10B981);
const Color kWarningColor = Color(0xFFF97316);
const Color kErrorColor = Color(0xFFEF4444);
