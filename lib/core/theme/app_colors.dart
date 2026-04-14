import 'package:flutter/material.dart';

/// Adsum renk paleti - Frontend (Angular) ile uyumlu
/// Primary: Blue, Success: Emerald, Warning: Amber, Error: Red
class AppColors {
  AppColors._();

  // ─── Primary Blue ───────────────────────────────────────────
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primarySurface = Color(0xFFEFF6FF);
  static const Color primarySurfaceDark = Color(0xFF1E3A5F);

  static const MaterialColor primarySwatch = MaterialColor(0xFF3B82F6, {
    50: Color(0xFFEFF6FF),
    100: Color(0xFFDBEAFE),
    200: Color(0xFFBFDBFE),
    300: Color(0xFF93C5FD),
    400: Color(0xFF60A5FA),
    500: Color(0xFF3B82F6),
    600: Color(0xFF2563EB),
    700: Color(0xFF1D4ED8),
    800: Color(0xFF1E40AF),
    900: Color(0xFF1E3A8A),
  });

  // ─── Success Green ──────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color successSurfaceDark = Color(0xFF064E3B);

  // ─── Warning Amber ──────────────────────────────────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningSurfaceDark = Color(0xFF78350F);

  // ─── Error Red ──────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color errorSurfaceDark = Color(0xFF7F1D1D);

  // ─── Info Blue ──────────────────────────────────────────────
  static const Color info = Color(0xFF6366F1);
  static const Color infoLight = Color(0xFF818CF8);
  static const Color infoDark = Color(0xFF4F46E5);
  static const Color infoSurface = Color(0xFFEEF2FF);

  // ─── Neutral / Gray ─────────────────────────────────────────
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ─── Light Theme ────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // ─── Dark Theme ─────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);

  // ─── Work Priority Colors ──────────────────────────────────
  static const Color priorityLow = Color(0xFF6B7280);
  static const Color priorityNormal = Color(0xFF3B82F6);
  static const Color priorityHigh = Color(0xFFF59E0B);
  static const Color priorityUrgent = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFEF4444);

  // ─── Work Step Status Colors ───────────────────────────────
  static const Color stepActive = Color(0xFF3B82F6);
  static const Color stepWaiting = Color(0xFFF59E0B);
  static const Color stepCompleted = Color(0xFF10B981);
  static const Color stepCancelled = Color(0xFFEF4444);
}
