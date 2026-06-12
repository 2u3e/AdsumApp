import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/mobile_work_provider.dart';
import '../widgets/work_list_body.dart';

/// "Atanan İşler" sayfası — kişiye atanan ofis işleri + ekibe atanan işler (yetkiyle),
/// tek birleşik listede scope rozetiyle. Başlık satırı WorkListBody içindedir.
class AssignedWorksScreen extends StatelessWidget {
  const AssignedWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
      body: const SafeArea(child: AssignedWorksView()),
    );
  }
}

/// Liste gövdesi (shell'siz).
class AssignedWorksView extends ConsumerWidget {
  const AssignedWorksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkListBody(
      works: ref.watch(assignedWorksProvider),
      onRefresh: () async => ref.invalidate(assignedWorksProvider),
      showScopeBadge: true,
      emptyTitle: 'Atanmış iş yok',
      emptyMessage: 'Size ya da ekibinize atanmış aktif iş bulunmuyor.',
    );
  }
}
