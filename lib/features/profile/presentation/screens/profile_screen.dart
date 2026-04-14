import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profil ve ayarlar ekrani
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            AppSpacing.verticalXl,

            // Kullanici avatari
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.initials ?? '??',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            AppSpacing.verticalLg,

            // Kullanici bilgileri
            Text(
              user?.fullName ?? 'Kullanıcı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            AppSpacing.verticalXs,
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            if (user?.roles.isNotEmpty ?? false) ...[
              AppSpacing.verticalXs,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  user!.roles.first,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],

            AppSpacing.verticalXxl,

            // Ayarlar listesi
            Card(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Koyu Tema',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        // TODO: Tema degistirme
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biyometrik Giriş',
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // TODO: Biyometrik giris toggle
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirim Tercihleri',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // TODO: Bildirim ayarlari sayfasi
                    },
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Hakkında',
                    subtitle: 'v1.0.0',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'ADSUM',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 Adsum Belediye Yönetim Sistemi',
                      );
                    },
                  ),
                ],
              ),
            ),

            AppSpacing.verticalXl,

            // Cikis butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Çıkış Yap'),
                      content: const Text('Oturumunuzu kapatmak istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Çıkış Yap',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    ref.read(authStateProvider.notifier).logout();
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text(
                  'Çıkış Yap',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }
}

/// Ayarlar satiri widget'i
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
