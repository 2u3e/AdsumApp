import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Is emri durumlari
enum WorkStatus {
  draft(1, 'Taslak'),
  pending(2, 'Beklemede'),
  inTransit(3, 'İntikalde'),
  inProgress(4, 'Devam Ediyor'),
  onHold(5, 'Beklemede (Durduruldu)'),
  completed(6, 'Tamamlandı'),
  cancelled(7, 'İptal Edildi');

  final int value;
  final String label;
  const WorkStatus(this.value, this.label);

  Color get color => switch (this) {
        draft => AppColors.gray400,
        pending => AppColors.warning,
        inTransit => AppColors.info,
        inProgress => AppColors.primary,
        onHold => AppColors.priorityUrgent,
        completed => AppColors.success,
        cancelled => AppColors.error,
      };

  Color get bgColor => switch (this) {
        draft => const Color(0xFFF3F4F6),
        pending => const Color(0xFFFFF8E1),
        inTransit => const Color(0xFFEDE7F6),
        inProgress => const Color(0xFFE3F2FD),
        onHold => const Color(0xFFFFF3E0),
        completed => const Color(0xFFE8F5E9),
        cancelled => const Color(0xFFFFEBEE),
      };

  Color get borderColor => color.withValues(alpha: 0.3);

  IconData get icon => switch (this) {
        draft => Icons.edit_note_rounded,
        pending => Icons.hourglass_empty_rounded,
        inTransit => Icons.directions_car_rounded,
        inProgress => Icons.engineering_rounded,
        onHold => Icons.pause_circle_outline_rounded,
        completed => Icons.check_circle_rounded,
        cancelled => Icons.cancel_rounded,
      };
}

/// Is emri oncelikleri
enum WorkPriority {
  low(1, 'Düşük'),
  normal(2, 'Normal'),
  high(3, 'Yüksek'),
  urgent(4, 'Acil'),
  critical(5, 'Kritik');

  final int value;
  final String label;
  const WorkPriority(this.value, this.label);

  Color get color => switch (this) {
        low => AppColors.gray400,
        normal => AppColors.primary,
        high => AppColors.warning,
        urgent => AppColors.priorityUrgent,
        critical => AppColors.error,
      };

  IconData get icon => switch (this) {
        low => Icons.arrow_downward_rounded,
        normal => Icons.remove_rounded,
        high => Icons.arrow_upward_rounded,
        urgent => Icons.priority_high_rounded,
        critical => Icons.warning_rounded,
      };
}

/// Is emri adim durumlari
enum WorkStepStatus {
  active(1, 'Aktif'),
  waiting(2, 'Bekliyor'),
  completed(3, 'Tamamlandı'),
  cancelled(4, 'İptal');

  final int value;
  final String label;
  const WorkStepStatus(this.value, this.label);

  Color get color => switch (this) {
        active => AppColors.primary,
        waiting => AppColors.warning,
        completed => AppColors.success,
        cancelled => AppColors.error,
      };
}
