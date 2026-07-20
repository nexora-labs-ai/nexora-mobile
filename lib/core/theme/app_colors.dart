import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Core Colors ───────────────────────────────────────────────────────────
  static const surface = Color(0xFFF7FBED);
  static const surfaceDim = Color(0xFFD8DCCE);
  static const surfaceBright = Color(0xFFF7FBED);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F5E8);
  static const surfaceContainer = Color(0xFFECF0E2);
  static const surfaceContainerHigh = Color(0xFFE6EADC);
  static const surfaceContainerHighest = Color(0xFFE0E4D7);
  static const onSurface = Color(0xFF191D15);
  static const onSurfaceVariant = Color(0xFF41493A);
  static const inverseSurface = Color(0xFF2D3229);
  static const inverseOnSurface = Color(0xFFEEF2E5);
  static const outline = Color(0xFF717A68);
  static const outlineVariant = Color(0xFFC1CAB5);

  static const primary = Color(0xFF2F6C00);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF9FE870); // Primary Action
  static const onPrimaryContainer = Color(0xFF2E6900);
  static const inversePrimary = Color(0xFF91D963);

  static const secondary = Color(0xFF4B6638);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFC9EAB0);
  static const onSecondaryContainer = Color(0xFF4F6A3C);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF7FBED);
  static const onBackground = Color(0xFF191D15);
  static const surfaceVariant = Color(0xFFE0E4D7);

  // Custom Aliases based on DESIGN.md
  static const canvas = Color(0xFFE8EBE6); // Sage
  static const ink = Color(0xFF0E0F0C); // Near Black
}
