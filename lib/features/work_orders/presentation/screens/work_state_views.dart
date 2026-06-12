import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Liste ekranlari icin ortak loading/error/empty gorunumleri.
class WorkLoadingView extends StatelessWidget {
  const WorkLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      ],
    );
  }
}

class WorkErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const WorkErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.gray400),
        const SizedBox(height: 12),
        const Center(child: Text('İşler yüklenemedi', style: TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(height: 4),
        const Center(
          child: Text('Bağlantıyı kontrol edip tekrar deneyin.',
              style: TextStyle(color: AppColors.gray500, fontSize: 13)),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Tekrar dene'),
          ),
        ),
      ],
    );
  }
}

class WorkEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const WorkEmptyView({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      children: [
        const SizedBox(height: 110),
        Icon(icon, size: 52, color: isDark ? AppColors.gray600 : AppColors.gray300),
        const SizedBox(height: 14),
        Center(
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
