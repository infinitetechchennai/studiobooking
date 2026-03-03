import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFFFF0000); // Flashoot Red
  static const Color primaryLight =
      Color(0xFFFF4D4D); // Softer red for hover/pressed

  // Secondary (used sparingly in Flashoot-style UI)
  static const Color secondaryOrange = Color(0xFFFF3B30); // Red-orange accent
  static const Color secondaryCyan =
      Color(0xFF2ECC71); // Success / confirmation
  static const Color secondaryPink = Color(0xFFE53935); // Alert / warning

  // Greys & Text
  static const Color grey1 = Color(0xFFFFFFFF); // Primary text (white)
  static const Color grey2 = Color(0xFFB0B0B0); // Secondary text
  static const Color grey3 = Color(0xFF2E2E2E); // Card / divider background

  // Base colors
  static const Color white = Colors.white;
  static const Color background =
      Color(0xFF000000); // Main background (Flashoot dark)

  // Shadows / borders
  static const Color shadowColor = Color(0xFF1A1A1A); // Subtle dark shadow
}
