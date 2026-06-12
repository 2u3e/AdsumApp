import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mobile_work.dart';
import 'work_visuals.dart';

/// İş detayını ayrı sayfaya gitmeden gösteren, sürüklenebilir alttan sheet.
/// Uzun açıklamalar burada serbestçe kaydırılır; kartta önizleme kırpılır.
Future<void> showWorkDetailSheet(BuildContext context, MobileWork work) {
  HapticFeedback.selectionClick();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.cardDark : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => _WorkDetailSheet(work: work),
  );
}

class _WorkDetailSheet extends StatelessWidget {
  final MobileWork work;
  const _WorkDetailSheet({required this.work});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = stepColorOf(work);
    final desc = work.cleanDescription;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray700 : AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(work.workTypeName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(work.code,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                    fontWeight: FontWeight.w600,
                                  )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(label: work.stepStatusName, color: accent),
                    if (work.stepName?.isNotEmpty == true && work.stepName != work.stepStatusName)
                      _Pill(label: work.stepName!, color: accent, outlined: true),
                    _Pill(label: priorityLabel(work.priority), color: priorityColor(work.priority), outlined: true),
                    _Pill(label: work.workGroupName, color: AppColors.gray500, outlined: true),
                  ],
                ),
                const SizedBox(height: 20),
                if (work.addressSummary.isNotEmpty)
                  _DetailRow(icon: Icons.place_rounded, title: 'Adres', value: work.addressSummary),
                if (work.buildingSummary != null)
                  _DetailRow(icon: Icons.home_work_rounded, title: 'Yapı', value: work.buildingSummary!),
                if (work.primaryAssigneeName?.isNotEmpty == true)
                  _DetailRow(icon: Icons.person_rounded, title: 'Atanan', value: work.primaryAssigneeName!),
                if (work.createdAt != null)
                  _DetailRow(icon: Icons.schedule_rounded, title: 'Oluşturulma', value: _fmtDate(work.createdAt!)),
                if (desc != null) ...[
                  const SizedBox(height: 8),
                  Text('Açıklama',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray800 : AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(desc,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = ['Oca','Şub','Mar','Nis','May','Haz','Tem','Ağu','Eyl','Eki','Kas','Ara'];
    final l = d.toLocal();
    final hh = l.hour.toString().padLeft(2, '0');
    final mm = l.minute.toString().padLeft(2, '0');
    return '${l.day} ${months[l.month - 1]} ${l.year}, $hh:$mm';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _DetailRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isDark ? AppColors.gray400 : AppColors.gray500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        )),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  const _Pill({required this.label, required this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: outlined ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
