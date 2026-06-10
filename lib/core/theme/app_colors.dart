import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────────────────────
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFFEEEDFF);
  static const secondary = Color(0xFFFF6584);
  static const accent = Color(0xFF43CEA2);

  // ─── Neutrals ─────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFFB0B7C3);

  // ─── Backgrounds ─────────────────────────────────────────────────────────
  static const backgroundLight = Color(0xFFF8F9FC);
  static const backgroundDark = Color(0xFF12131A);
  static const surfaceLight = Color(0xFFF0F1F5);
  static const surfaceDark = Color(0xFF1E1F28);

  // ─── Status ───────────────────────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // ─── Finance ──────────────────────────────────────────────────────────────
  static const debit = Color(0xFFEF4444);
  static const credit = Color(0xFF22C55E);
  static const neutral = Color(0xFF6B7280);

  // ─── Misc ─────────────────────────────────────────────────────────────────
  static const divider = Color(0xFFE5E7EB);
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);
}
