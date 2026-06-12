import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mobile_work_provider.dart';
import '../widgets/mobile_work_card.dart';
import 'work_state_views.dart';

/// Sayfa A gövdesi — "Atanan İşler". Kişiye atanan ofis işleri (her zaman) + ekibe
/// atanan işler (Ekip İşleri yetkisi varsa) tek birleşik listede, scope rozetiyle.
/// Shell (AppBar + birim seçici + TabBar) [WorksTabsScreen] tarafından sağlanır.
class AssignedWorksView extends ConsumerWidget {
  const AssignedWorksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorks = ref.watch(assignedWorksProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(assignedWorksProvider),
      child: asyncWorks.when(
        loading: () => const WorkLoadingView(),
        error: (e, _) => WorkErrorView(onRetry: () => ref.invalidate(assignedWorksProvider)),
        data: (works) {
          if (works.isEmpty) {
            return const WorkEmptyView(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Atanmış iş yok',
              message: 'Size ya da ekibinize atanmış aktif iş bulunmuyor.',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: works.length,
            itemBuilder: (_, i) => MobileWorkCard(work: works[i], showScopeBadge: true),
          );
        },
      ),
    );
  }
}
