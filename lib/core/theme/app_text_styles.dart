import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // ─── Display ──────────────────────────────────────────────────────────────
  static final displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.92, // -0.04em
    height: 1.1,
    color: AppColors.onSurface,
  );

  static final displayMedium = GoogleFonts.plusJakartaSans(
    // mapped to display-lg-mobile
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.64, // -0.02em
    height: 1.1,
    color: AppColors.onSurface,
  );

  // ─── Headline ─────────────────────────────────────────────────────────────
  static final headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.24, // -0.01em
    height: 1.2,
    color: AppColors.onSurface,
  );

  // ─── Body ─────────────────────────────────────────────────────────────────
  static final bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static final bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.onSurface,
  );

  // ─── Label ────────────────────────────────────────────────────────────────
  static final labelSmall = GoogleFonts.inter(
    // mapped to label-caps
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6, // 0.05em
    height: 1.0,
    color: AppColors.onSurfaceVariant,
  );

  static final TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineMedium: headlineMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelSmall: labelSmall,
  );
}
