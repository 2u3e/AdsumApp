import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/mobile_work_provider.dart';
import '../widgets/work_list_body.dart';

/// "Birim İşleri" sayfası — aktif birimde ve alt birimlerinde bekleyen
/// (atama durumundaki) işler. Başlık satırı WorkListBody içindedir.
class UnitWorksScreen extends StatelessWidget {
  const UnitWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
      body: const SafeArea(child: UnitWorksView()),
    );
  }
}

/// Liste gövdesi (shell'siz).
class UnitWorksView extends ConsumerWidget {
  const UnitWorksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkListBody(
      works: ref.watch(unitWorksProvider),
      onRefresh: () async => ref.invalidate(unitWorksProvider),
      emptyTitle: 'Bekleyen iş yok',
      emptyMessage: 'Birimlerinizde dağıtım bekleyen iş bulunmuyor.',
    );
  }
}
