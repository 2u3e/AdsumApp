import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mobile_work.dart';

/// İş kartı/sheet görselleri için ortak yardımcılar — adım rengi, durum ikonu, öncelik.

/// "#RRGGBB" / "#AARRGGBB" hex → Color. Geçersizse [fallback].
Color colorFromHex(String? hex, {Color fallback = AppColors.primary}) {
  if (hex == null) return fallback;
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return fallback;
  final v = int.tryParse(h, radix: 16);
  return v == null ? fallback : Color(v);
}

/// İş adımının rengi (admin tanımlı). Yoksa primary.
Color stepColorOf(MobileWork w) => colorFromHex(w.stepColor, fallback: AppColors.primary);

/// İş durumuna (StepStatusId) karşılık Material ikon. WorkStepStatuses enum ID'leri.
IconData statusIcon(int stepStatusId) {
  switch (stepStatusId) {
    case 1230001: // AtamaDurumunda — dağıtım bekliyor
      return Icons.inbox_rounded;
    case 1230002: // Başlanıldı
      return Icons.play_circle_fill_rounded;
    case 1230003: // Bekleme
      return Icons.pause_circle_filled_rounded;
    case 1230004: // Tamamlandı
      return Icons.check_circle_rounded;
    case 1230005: // İptal
      return Icons.cancel_rounded;
    case 1230006: // Onay
      return Icons.verified_rounded;
    default:
      return Icons.assignment_rounded;
  }
}

/// Öncelik rengi (1..5).
Color priorityColor(int priority) {
  switch (priority) {
    case 5:
      return const Color(0xFFDC2626);
    case 4:
      return const Color(0xFFEA580C);
    case 3:
      return const Color(0xFFF59E0B);
    case 2:
      return const Color(0xFF10B981);
    default:
      return const Color(0xFF6B7280);
  }
}

/// Göreli tarih: Bugün → "Bugün HH:mm", dün → "Dün", sonrası → "N gün önce".
String relativeDate(DateTime? dt) {
  if (dt == null) return '';
  final l = dt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(l.year, l.month, l.day);
  final days = today.difference(that).inDays;
  if (days <= 0) {
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return 'Bugün $hh:$mm';
  }
  if (days == 1) return 'Dün';
  return '$days gün önce';
}

String priorityLabel(int priority) {
  switch (priority) {
    case 5:
      return 'Kritik';
    case 4:
      return 'Yüksek';
    case 3:
      return 'Orta';
    case 2:
      return 'Düşük';
    default:
      return 'Çok Düşük';
  }
}
