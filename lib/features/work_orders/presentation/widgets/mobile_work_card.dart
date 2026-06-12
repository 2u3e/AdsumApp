import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mobile_work.dart';

/// Mobil is karti — liste satiri. Sayfa A'da scope rozeti (Bana / Ekip) gosterilir.
class MobileWorkCard extends StatelessWidget {
  final MobileWork work;
  final bool showScopeBadge;
  final VoidCallback? onTap;
  const MobileWorkCard({
    super.key,
    required this.work,
    this.showScopeBadge = false,
    this.onTap,
  });

  Color _priorityColor() {
    switch (work.priority) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _priorityColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol oncelik seridi
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              work.workTypeName.isEmpty ? '(İş tipi yok)' : work.workTypeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (showScopeBadge) _ScopeBadge(scope: work.scope, isDark: isDark),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        work.code,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (work.addressSummary.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 13, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                work.addressSummary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatusChip(label: work.stepStatusName, isDark: isDark),
                          const Spacer(),
                          if (work.primaryAssigneeName?.isNotEmpty == true)
                            Flexible(
                              child: Text(
                                work.primaryAssigneeName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeBadge extends StatelessWidget {
  final MobileWorkScope scope;
  final bool isDark;
  const _ScopeBadge({required this.scope, required this.isDark});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (scope) {
      case MobileWorkScope.personal:
        label = 'Bana';
        color = AppColors.primary;
        break;
      case MobileWorkScope.team:
        label = 'Ekip';
        color = const Color(0xFF8B5CF6);
        break;
      case MobileWorkScope.unit:
        label = 'Birim';
        color = const Color(0xFF0EA5E9);
        break;
    }
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _StatusChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
