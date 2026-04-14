import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Kullanici durumu
enum UserWorkStatus {
  working('Çalışıyorum', Icons.work_rounded, AppColors.success),
  onBreak('Moladayım', Icons.coffee_rounded, AppColors.warning),
  endOfDay('Gün Sonu', Icons.nightlight_round, AppColors.gray500);

  final String label;
  final IconData icon;
  final Color color;
  const UserWorkStatus(this.label, this.icon, this.color);
}

/// Profil ve ayarlar ekrani
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserWorkStatus _workStatus = UserWorkStatus.working;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            AppSpacing.verticalXl,

            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.initials ?? 'TK',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _workStatus.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, width: 3),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalLg,

            // Kullanici bilgileri
            Text(
              user?.fullName ?? 'Test Kullanıcı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            AppSpacing.verticalXs,
            Text(
              user?.email ?? 'test@adsum.gov',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
            ),
            AppSpacing.verticalXs,
            if (user?.organizationName != null || user?.departmentName != null)
              Text(
                user?.departmentName ?? user?.organizationName ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
              ),
            AppSpacing.verticalSm,
            if (user?.roles.isNotEmpty ?? false)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: AppSpacing.borderRadiusFull,
                ),
                child: Text(
                  user!.roles.first,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                ),
              ),

            AppSpacing.verticalXxl,

            // Durum ayari
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('Durum', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Row(
                      children: UserWorkStatus.values.map((status) {
                        final selected = _workStatus == status;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(status.icon, size: 14, color: selected ? Colors.white : status.color),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      status.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: selected ? Colors.white : null),
                                    ),
                                  ),
                                ],
                              ),
                              selected: selected,
                              selectedColor: status.color,
                              onSelected: (_) => setState(() => _workStatus = status),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.verticalMd,

            // Ayarlar
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    title: const Text('Koyu Tema'),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggleDark(),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Bildirim Tercihleri'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: const Text('Dil'),
                    subtitle: const Text('Türkçe'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Hakkında'),
                    subtitle: const Text('ADSUM v1.0.0'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'ADSUM',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '2026 Adsum Belediye Yönetim Sistemi',
                      );
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,

            // Cikis
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
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    ref.read(authStateProvider.notifier).logout();
                  }
                },
                icon: Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
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
