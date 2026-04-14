import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Bildirim listesi ekrani
class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Tumunu okundu isaretle
            },
            child: const Text('Tümünü Oku'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: isDark ? AppColors.gray600 : AppColors.gray300,
            ),
            AppSpacing.verticalLg,
            Text(
              'Bildirim yok',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            AppSpacing.verticalSm,
            Text(
              'Push bildirimler Firebase Cloud Messaging\nentegrasyonu ile aktif olacak',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
