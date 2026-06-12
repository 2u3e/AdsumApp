import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mobile_work_provider.dart';
import '../widgets/mobile_work_card.dart';
import 'work_state_views.dart';

/// Sayfa B gövdesi — "Birim İşleri". Kullanıcının yetkili olduğu birimlerde bekleyen
/// (atama durumundaki) işler. Yetki kontrolü [WorksTabsScreen] sekme görünürlüğüyle
/// yapılır; bu görünüm doğrudan veriyi listeler.
class UnitWorksView extends ConsumerWidget {
  const UnitWorksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorks = ref.watch(unitWorksProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(unitWorksProvider),
      child: asyncWorks.when(
        loading: () => const WorkLoadingView(),
        error: (e, _) => WorkErrorView(onRetry: () => ref.invalidate(unitWorksProvider)),
        data: (works) {
          if (works.isEmpty) {
            return const WorkEmptyView(
              icon: Icons.inbox_outlined,
              title: 'Bekleyen iş yok',
              message: 'Birimlerinizde dağıtım bekleyen iş bulunmuyor.',
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: works.length,
            itemBuilder: (_, i) => MobileWorkCard(work: works[i]),
          );
        },
      ),
    );
  }
}
