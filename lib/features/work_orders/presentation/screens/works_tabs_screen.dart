import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/mobile_menu_provider.dart';
import '../widgets/active_org_selector.dart';
import 'assigned_works_screen.dart';
import 'unit_works_screen.dart';

/// "İşler" sekmesi kabuğu. Üstte aktif birim seçici; içerikte iki sayfa:
///   - "Atanan İşler" (her zaman) — kişiye + ekibe atanan işler.
///   - "Birim İşleri" (yalnız yetki varsa) — birimde bekleyen işler.
/// "Birim İşleri" yetkisi yoksa TabBar gizlenir, tek sayfa gösterilir.
class WorksTabsScreen extends ConsumerWidget {
  const WorksTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canUnit = ref.watch(canSeeUnitWorksProvider);

    if (!canUnit) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
        appBar: AppBar(
          title: const Text('İşler', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: const [
            Padding(padding: EdgeInsets.only(right: 12), child: Center(child: ActiveOrgSelector())),
          ],
        ),
        body: const SafeArea(top: false, child: AssignedWorksView()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
        appBar: AppBar(
          title: const Text('İşler', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: const [
            Padding(padding: EdgeInsets.only(right: 12), child: Center(child: ActiveOrgSelector())),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.gray400 : AppColors.gray500,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            tabs: const [
              Tab(text: 'Atanan İşler'),
              Tab(text: 'Birim İşleri'),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              AssignedWorksView(),
              UnitWorksView(),
            ],
          ),
        ),
      ),
    );
  }
}
