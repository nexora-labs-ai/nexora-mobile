import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  // ─── Display ──────────────────────────────────────────────────────────────
  static const displayLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const displayMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  // ─── Headline ─────────────────────────────────────────────────────────────
  static const headlineLarge = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const headlineMedium = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const headlineSmall = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  // ─── Title ────────────────────────────────────────────────────────────────
  static const titleLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const titleMedium = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const titleSmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  // ─── Body ─────────────────────────────────────────────────────────────────
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // ─── Label ────────────────────────────────────────────────────────────────
  static const labelLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2);
  static const labelMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const labelSmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4);

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
