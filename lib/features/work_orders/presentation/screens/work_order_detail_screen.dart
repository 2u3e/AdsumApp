import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_work_orders.dart';
import '../../domain/entities/work_enums.dart';
import '../../domain/entities/work_order.dart';

/// Is emri detay ekrani
class WorkOrderDetailScreen extends ConsumerWidget {
  final String workOrderId;

  const WorkOrderDetailScreen({super.key, required this.workOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = mockWorkOrders.firstWhere(
      (w) => w.id == workOrderId,
      orElse: () => mockWorkOrders.first,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: order.status.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.workNumber,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                  ),
                  Text(
                    order.workTypeName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _showMoreMenu(context, order),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalLg,

                  // Durum + Oncelik satiri
                  Row(
                    children: [
                      _StatusChip(status: order.status),
                      AppSpacing.horizontalSm,
                      _PriorityChip(priority: order.priority),
                      const Spacer(),
                      Text(
                        'Bekleme: ${order.waitingDuration}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                            ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalLg,

                  // Ilerleme cubugu
                  if (order.completionPercentage > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('İlerleme', style: Theme.of(context).textTheme.labelMedium),
                        Text('${order.completionPercentage.toInt()}%',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    AppSpacing.verticalXs,
                    ClipRRect(
                      borderRadius: AppSpacing.borderRadiusFull,
                      child: LinearProgressIndicator(
                        value: order.completionPercentage / 100,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.gray700 : AppColors.gray200,
                        color: order.status.color,
                      ),
                    ),
                    AppSpacing.verticalLg,
                  ],

                  // Islem butonlari
                  if (order.status != WorkStatus.completed && order.status != WorkStatus.cancelled)
                    _ActionButtons(order: order),

                  AppSpacing.verticalLg,

                  // Bilgi kartlari
                  _InfoSection(title: 'Açıklama', icon: Icons.description_outlined, child: Text(
                    order.description ?? 'Açıklama girilmemiş.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
                  AppSpacing.verticalMd,

                  _InfoSection(title: 'Konum', icon: Icons.location_on_outlined, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.fullAddress, style: Theme.of(context).textTheme.bodyMedium),
                      if (order.latitude != null) ...[
                        AppSpacing.verticalSm,
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.map_outlined, size: 18),
                            label: const Text('Haritada Göster'),
                          ),
                        ),
                      ],
                    ],
                  )),
                  AppSpacing.verticalMd,

                  _InfoSection(title: 'Başvuran', icon: Icons.person_outline_rounded, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.applicantName != null) Text(order.applicantName!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      if (order.applicantPhone != null) ...[
                        AppSpacing.verticalXs,
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                            AppSpacing.horizontalXs,
                            Text(order.applicantPhone!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ],
                      if (order.applicantName == null) Text('Başvuran bilgisi yok', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400)),
                    ],
                  )),
                  AppSpacing.verticalMd,

                  if (order.assigneeName != null)
                    _InfoSection(title: 'Atanan Personel', icon: Icons.engineering_outlined, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.assigneeName!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (order.assigneeDepartment != null)
                          Text(order.assigneeDepartment!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    )),

                  if (order.assigneeName != null) AppSpacing.verticalMd,

                  // Tarih bilgileri
                  _InfoSection(title: 'Tarihler', icon: Icons.calendar_today_outlined, child: Column(
                    children: [
                      _DateRow(label: 'Oluşturulma', date: order.createdAt),
                      if (order.dueDate != null) _DateRow(label: 'Termin', date: order.dueDate!),
                      if (order.startedAt != null) _DateRow(label: 'Başlangıç', date: order.startedAt!),
                      if (order.completedAt != null) _DateRow(label: 'Tamamlanma', date: order.completedAt!),
                    ],
                  )),
                  AppSpacing.verticalMd,

                  // Adim zaman cizelgesi
                  if (order.steps.isNotEmpty) ...[
                    _InfoSection(title: 'Adımlar', icon: Icons.timeline_rounded, child: _StepTimeline(steps: order.steps)),
                    AppSpacing.verticalMd,
                  ],

                  // Is gecmisi
                  if (order.history.isNotEmpty) ...[
                    _InfoSection(title: 'İş Geçmişi', icon: Icons.history_rounded, child: _HistoryTimeline(history: order.history)),
                    AppSpacing.verticalMd,
                  ],

                  // Ekler
                  _InfoSection(title: 'Ekler & Yorumlar', icon: Icons.attach_file_rounded, child: Row(
                    children: [
                      _CountBadge(icon: Icons.photo_outlined, count: order.attachmentCount, label: 'Fotoğraf'),
                      AppSpacing.horizontalMd,
                      _CountBadge(icon: Icons.chat_bubble_outline_rounded, count: order.commentCount, label: 'Yorum'),
                    ],
                  )),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context, WorkOrder order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 16), decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull)),
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Düzenle'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.person_add_outlined), title: const Text('Yeniden Ata'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.forward_outlined), title: const Text('Yönlendir'), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.cancel_outlined, color: AppColors.error), title: Text('İptal Et', style: TextStyle(color: AppColors.error)), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

/// Islem butonlari - duruma gore dinamik
class _ActionButtons extends StatelessWidget {
  final WorkOrder order;
  const _ActionButtons({required this.order});

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    switch (order.status) {
      case WorkStatus.pending:
        actions.addAll([
          _buildAction(context, 'İntikal Et', Icons.directions_car_rounded, AppColors.info, () => _showActionDialog(context, 'İntikal', order)),
        ]);
      case WorkStatus.inTransit:
        actions.addAll([
          _buildAction(context, 'Başla', Icons.play_circle_outline_rounded, AppColors.success, () => _showActionDialog(context, 'Başla', order)),
        ]);
      case WorkStatus.inProgress:
        actions.addAll([
          _buildAction(context, 'Beklet', Icons.pause_circle_outline_rounded, AppColors.warning, () => _showHoldDialog(context, order)),
          _buildAction(context, 'Sonlandır', Icons.check_circle_outline_rounded, AppColors.success, () => _showCompleteDialog(context, order)),
        ]);
      case WorkStatus.onHold:
        actions.addAll([
          _buildAction(context, 'Devam Et', Icons.play_circle_outline_rounded, AppColors.primary, () => _showActionDialog(context, 'Devam', order)),
        ]);
      default:
        break;
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }

  Widget _buildAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String action, WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${order.workNumber} numaralı iş emri için "$action" işlemi yapılacak.'),
            AppSpacing.verticalLg,
            const TextField(decoration: InputDecoration(labelText: 'Not (opsiyonel)', hintText: 'Açıklama ekleyin...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(action)),
        ],
      ),
    );
  }

  void _showHoldDialog(BuildContext context, WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beklemeye Al'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('İşi neden beklemeye alıyorsunuz?'),
            AppSpacing.verticalLg,
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Bekleme Nedeni'),
              items: const [
                DropdownMenuItem(value: 'equipment', child: Text('Ekipman/Araç Bekleniyor')),
                DropdownMenuItem(value: 'material', child: Text('Malzeme Bekleniyor')),
                DropdownMenuItem(value: 'weather', child: Text('Hava Koşulları Uygun Değil')),
                DropdownMenuItem(value: 'permission', child: Text('İzin/Onay Bekleniyor')),
                DropdownMenuItem(value: 'other', child: Text('Diğer')),
              ],
              onChanged: (_) {},
            ),
            AppSpacing.verticalMd,
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Açıklama', hintText: 'Detay bilgi girin...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Beklemeye Al'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, WorkOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşi Sonlandır'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('İşi tamamlamak için aşağıdaki bilgileri doldurun.'),
              AppSpacing.verticalLg,
              const TextField(
                decoration: InputDecoration(labelText: 'Yapılan İş Açıklaması', hintText: 'Yapılan işlemi açıklayın...'),
                maxLines: 3,
              ),
              AppSpacing.verticalMd,
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Metraj (m²)', hintText: 'Örn: 15'),
              ),
              AppSpacing.verticalMd,
              const TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Personel Sayısı', hintText: 'Örn: 3'),
              ),
              AppSpacing.verticalMd,
              const TextField(
                decoration: InputDecoration(labelText: 'Kullanılan Malzeme', hintText: 'Malzeme listesi...'),
                maxLines: 2,
              ),
              AppSpacing.verticalMd,
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Fotoğraf Ekle'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Tamamla'),
          ),
        ],
      ),
    );
  }
}

/// Bilgi bolumu karti
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _InfoSection({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                AppSpacing.horizontalSm,
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            AppSpacing.verticalMd,
            child,
          ],
        ),
      ),
    );
  }
}

/// Tarih satiri
class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  const _DateRow({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          Text(
            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Durum chip'i
class _StatusChip extends StatelessWidget {
  final WorkStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusFull,
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(status.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: status.color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Oncelik chip'i
class _PriorityChip extends StatelessWidget {
  final WorkPriority priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 12, color: priority.color),
          const SizedBox(width: 4),
          Text(priority.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: priority.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Adim timeline
class _StepTimeline extends StatelessWidget {
  final List<WorkStep> steps;
  const _StepTimeline({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: step.status == WorkStepStatus.completed
                            ? step.status.color
                            : step.status == WorkStepStatus.active
                                ? step.status.color
                                : Colors.transparent,
                        border: Border.all(color: step.status.color, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: step.status == WorkStepStatus.completed
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : step.status == WorkStepStatus.active
                              ? const Icon(Icons.circle, size: 8, color: Colors.white)
                              : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.status == WorkStepStatus.completed ? step.status.color : AppColors.gray300,
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: step.status == WorkStepStatus.active ? FontWeight.w700 : FontWeight.w500,
                          )),
                      if (step.assignee != null)
                        Text(step.assignee!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Is gecmisi timeline
class _HistoryTimeline extends StatelessWidget {
  final List<WorkHistoryEntry> history;
  const _HistoryTimeline({required this.history});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reversed = history.reversed.toList();

    return Column(
      children: List.generate(reversed.length, (index) {
        final entry = reversed[index];
        final isLast = index == reversed.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: index == 0 ? AppColors.primary : AppColors.gray400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 1, color: AppColors.gray300)),
                  ],
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.action, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            '${entry.performedAt.hour.toString().padLeft(2, '0')}:${entry.performedAt.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                          ),
                        ],
                      ),
                      Text(entry.description, style: Theme.of(context).textTheme.bodySmall),
                      Text(entry.performedBy, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.gray500)),
                      if (entry.note != null) ...[
                        AppSpacing.verticalXs,
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.gray800 : AppColors.gray100,
                            borderRadius: AppSpacing.borderRadiusSm,
                          ),
                          child: Text(entry.note!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                        ),
                      ],
                      if (entry.attachmentUrls.isNotEmpty) ...[
                        AppSpacing.verticalXs,
                        Row(children: [
                          Icon(Icons.photo_outlined, size: 14, color: AppColors.primary),
                          AppSpacing.horizontalXs,
                          Text('${entry.attachmentUrls.length} fotoğraf', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Sayi badge'i
class _CountBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  const _CountBadge({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray500),
        AppSpacing.horizontalXs,
        Text('$count $label', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
