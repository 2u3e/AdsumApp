import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/active_org_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/membership.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// App bar'a yerlestirilen aktif birim chip'i. Tiklayinca alttan secici sheet acilir.
/// Tek uyelik varsa sadece ad gosterilir (acilmaz). Web header birim secicinin muadili.
class ActiveOrgSelector extends ConsumerWidget {
  const ActiveOrgSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final memberships =
        ref.watch(authStateProvider.select((s) => s.value?.user?.memberships ?? const <Membership>[]));
    final active = ref.watch(activeMembershipProvider);
    if (memberships.isEmpty) return const SizedBox.shrink();

    final single = memberships.length == 1;

    return InkWell(
      onTap: single ? null : () => _openSheet(context, ref, memberships, active),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.apartment_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(
                active?.displayName ?? 'Birim seç',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (!single) ...[
              const SizedBox(width: 2),
              Icon(Icons.expand_more_rounded,
                  size: 18, color: isDark ? AppColors.gray400 : AppColors.gray500),
            ],
          ],
        ),
      ),
    );
  }

  void _openSheet(
    BuildContext context,
    WidgetRef ref,
    List<Membership> memberships,
    Membership? active,
  ) {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Text('Aktif Birim',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: memberships.length,
                itemBuilder: (_, i) {
                  final m = memberships[i];
                  final selected = m.organizationId == active?.organizationId;
                  return ListTile(
                    onTap: () {
                      ref.read(activeOrganizationProvider.notifier).setActive(m.organizationId);
                      Navigator.of(ctx).pop();
                    },
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: (m.isFieldTeam ? const Color(0xFF8B5CF6) : AppColors.primary)
                          .withValues(alpha: 0.14),
                      child: Icon(
                        m.isFieldTeam ? Icons.groups_rounded : Icons.apartment_rounded,
                        size: 18,
                        color: m.isFieldTeam ? const Color(0xFF8B5CF6) : AppColors.primary,
                      ),
                    ),
                    title: Text(m.organizationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: m.rolesSummary.isEmpty
                        ? null
                        : Text(m.rolesSummary, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
