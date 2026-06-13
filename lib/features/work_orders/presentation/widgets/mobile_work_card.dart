import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mobile_work.dart';
import 'work_detail_sheet.dart';
import 'work_visuals.dart';

/// Mobil iş kartı — kompakt; solda iş adımı renginde accent bar.
/// Satır1: numara + durum + öncelik + tarih. Dokunulunca detay sheet açılır.
class MobileWorkCard extends StatelessWidget {
  final MobileWork work;
  final bool showScopeBadge;

  /// Kuş uçuşu mesafe metni (hazır biçimli) — konum varsa.
  final String? crowText;

  /// Araçla mesafe metni (hazır biçimli) — OSRM açık ve metrik varsa.
  final String? driveText;

  const MobileWorkCard({
    super.key,
    required this.work,
    this.showScopeBadge = false,
    this.crowText,
    this.driveText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = stepColorOf(work);
    final desc = work.cleanDescription;
    final muted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
    final secondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            showWorkDetailSheet(context, work, crowText: crowText, driveText: driveText);
          },
          splashColor: accent.withValues(alpha: 0.07),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3.5, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 7, 11, 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Satır 1: numara + durum + öncelik ......... tarih
                          Row(
                            children: [
                              Text(
                                work.code,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                              const SizedBox(width: 5),
                              // Durum ortayı doldurur → öncelik + tarih sağa yaslanır.
                              Expanded(
                                child: Text(
                                  work.stepStatusName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(color: accent, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.flag_rounded, size: 13, color: priorityColor(work.priority)),
                              const SizedBox(width: 6),
                              Text(
                                relativeDate(work.createdAt),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          // Satır 2: iş tipi + mesafeler (yan yana) (+ scope rozeti)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  work.workTypeName.isEmpty ? '(İş tipi yok)' : work.workTypeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (crowText != null) ...[
                                const SizedBox(width: 8),
                                _DistMini(icon: Icons.near_me_rounded, text: crowText!, color: muted),
                              ],
                              if (driveText != null) ...[
                                const SizedBox(width: 6),
                                _DistMini(icon: Icons.directions_car_rounded, text: driveText!, color: accent, strong: true),
                              ],
                              if (showScopeBadge) ...[
                                const SizedBox(width: 8),
                                _ScopeBadge(scope: work.scope, isDark: isDark),
                              ],
                            ],
                          ),
                          if (work.addressSummary.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 13, color: muted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    work.addressSummary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondary, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (desc != null && desc.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DistMini extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool strong;
  const _DistMini({required this.icon, required this.text, required this.color, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: strong ? FontWeight.w700 : FontWeight.w500)),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
