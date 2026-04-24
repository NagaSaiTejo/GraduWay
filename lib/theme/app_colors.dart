import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary — Indigo ──────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF4F46E5); // indigo-600
  static const Color primaryLight   = Color(0xFF818CF8); // indigo-400
  static const Color primaryDark    = Color(0xFF3730A3); // indigo-800
  static const Color primarySurface = Color(0xFFEEF2FF); // indigo-50

  // ── Student accent — Teal/Sky ─────────────────────────────────────────────
  static const Color secondary      = Color(0xFF0EA5E9); // sky-500
  static const Color secondaryLight = Color(0xFF38BDF8); // sky-400
  static const Color secondarySurface = Color(0xFFE0F2FE); // sky-50

  // ── Alumni accent — Emerald ───────────────────────────────────────────────
  static const Color alumni         = Color(0xFF059669); // emerald-600
  static const Color alumniLight    = Color(0xFF34D399); // emerald-400
  static const Color alumniSurface  = Color(0xFFD1FAE5); // emerald-100

  // ── Admin accent — Amber ──────────────────────────────────────────────────
  static const Color admin          = Color(0xFFF59E0B); // amber-500
  static const Color adminLight     = Color(0xFFFCD34D); // amber-300
  static const Color adminSurface   = Color(0xFFFEF3C7); // amber-100

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent         = Color(0xFFF59E0B); // amber
  static const Color accentSurface  = Color(0xFFFEF3C7);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF10B981); // emerald-500
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color error          = Color(0xFFEF4444); // red-500
  static const Color errorSurface   = Color(0xFFFEE2E2);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color info           = Color(0xFF3B82F6);
  static const Color infoSurface    = Color(0xFFDBEAFE);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bgPage         = Color(0xFFF8F9FF); // very light indigo-white
  static const Color bgCard         = Color(0xFFFFFFFF);
  static const Color bgCardAlt      = Color(0xFFF1F5F9); // slate-100
  static const Color bgCardLight    = Color(0xFFFAFAFF);
  static const Color bgDark         = Color(0xFF1E1B4B); // deep indigo (for headers)

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1E1B4B); // deep indigo
  static const Color textSecondary  = Color(0xFF475569); // slate-600
  static const Color textMuted      = Color(0xFF94A3B8); // slate-400
  static const Color textOnDark     = Color(0xFFFFFFFF);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border         = Color(0xFFE2E8F0); // slate-200
  static const Color borderFocus    = Color(0xFF4F46E5);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient alumniGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0EA5E9)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF4F46E5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF8F9FF), Color(0xFFEEF2FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF4F46E5).withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF4F46E5).withOpacity(0.18),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
