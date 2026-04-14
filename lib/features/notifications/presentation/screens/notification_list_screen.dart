import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Bildirim tipi
enum NotificationType {
  workAssigned(Icons.assignment_ind_rounded, AppColors.primary, 'Atama'),
  workUpdated(Icons.update_rounded, AppColors.info, 'Güncelleme'),
  workCompleted(Icons.check_circle_rounded, AppColors.success, 'Tamamlandı'),
  workOverdue(Icons.warning_rounded, AppColors.error, 'Gecikme'),
  system(Icons.settings_rounded, AppColors.gray500, 'Sistem'),
  message(Icons.chat_rounded, AppColors.warning, 'Mesaj');

  final IconData icon;
  final Color color;
  final String label;
  const NotificationType(this.icon, this.color, this.label);
}

/// Bildirim modeli
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedWorkId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.relatedWorkId,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    return '${diff.inDays} gün';
  }
}

/// Mock bildirimler
final List<AppNotification> _mockNotifications = [
  AppNotification(
    id: '1', type: NotificationType.workAssigned,
    title: 'Yeni İş Emri Atandı',
    body: 'W-26-00187 Asfalt Onarım - Tecde Mah. İnönü Cad. size atandı.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    relatedWorkId: '1',
  ),
  AppNotification(
    id: '2', type: NotificationType.workOverdue,
    title: 'Geciken İş Emri',
    body: 'W-26-00182 Trafik İşareti - termin tarihi geçti!',
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    relatedWorkId: '6',
  ),
  AppNotification(
    id: '3', type: NotificationType.workUpdated,
    title: 'İş Emri Güncellendi',
    body: 'W-26-00186 Su Kesintisi - Hasan Korkmaz sahaya intikal etti.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: true,
    relatedWorkId: '2',
  ),
  AppNotification(
    id: '4', type: NotificationType.message,
    title: 'Ali Kaya yorum ekledi',
    body: 'W-26-00187: "Asfalt yama malzemesi depoda hazır, alabilirsiniz."',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
    relatedWorkId: '1',
  ),
  AppNotification(
    id: '5', type: NotificationType.workCompleted,
    title: 'İş Emri Tamamlandı',
    body: 'W-26-00184 Ağaç Budama - Veli Çelik tarafından tamamlandı.',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    isRead: true,
    relatedWorkId: '4',
  ),
  AppNotification(
    id: '6', type: NotificationType.system,
    title: 'Sistem Bakımı',
    body: 'Yarın 02:00-04:00 arası planlı bakım yapılacaktır.',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    isRead: true,
  ),
  AppNotification(
    id: '7', type: NotificationType.workAssigned,
    title: 'İş Emri Yönlendirildi',
    body: 'W-26-00175 Su Arızası size yönlendirildi. Acil müdahale gerekiyor.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    relatedWorkId: '13',
  ),
  AppNotification(
    id: '8', type: NotificationType.workCompleted,
    title: 'İş Emri Tamamlandı',
    body: 'W-26-00177 Kazı İzni Denetimi - Serkan Acar tarafından tamamlandı.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    isRead: true,
    relatedWorkId: '11',
  ),
];

/// Bildirim listesi ekrani
class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends ConsumerState<NotificationListScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_mockNotifications);
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Bildirimler'),
            if (_unreadCount > 0) ...[
              AppSpacing.horizontalSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _notifications = _notifications.map((n) => AppNotification(
                  id: n.id, type: n.type, title: n.title, body: n.body,
                  createdAt: n.createdAt, isRead: true, relatedWorkId: n.relatedWorkId,
                )).toList();
              });
            },
            child: const Text('Tümünü Oku'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty(context, isDark)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: AppColors.error,
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _notifications.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Bildirim silindi'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Geri Al',
                          onPressed: () {
                            setState(() => _notifications.insert(index, notif));
                          },
                        ),
                      ),
                    );
                  },
                  child: _NotificationTile(
                    notification: notif,
                    onTap: () {
                      // Okundu isaretle
                      if (!notif.isRead) {
                        setState(() {
                          _notifications[index] = AppNotification(
                            id: notif.id, type: notif.type, title: notif.title, body: notif.body,
                            createdAt: notif.createdAt, isRead: true, relatedWorkId: notif.relatedWorkId,
                          );
                        });
                      }
                      // TODO: Ilgili is emrine git
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64,
              color: isDark ? AppColors.gray600 : AppColors.gray300),
          AppSpacing.verticalLg,
          Text('Bildirim yok', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Bildirim satiri
class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark ? AppColors.primarySurfaceDark.withValues(alpha: 0.3) : AppColors.primarySurface.withValues(alpha: 0.5))
              : null,
          border: Border(
            bottom: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.type.color.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(notification.type.icon, size: 20, color: notification.type.color),
            ),
            AppSpacing.horizontalMd,

            // Icerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                            ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Okunmadi gostergesi
            if (isUnread) ...[
              AppSpacing.horizontalSm,
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
