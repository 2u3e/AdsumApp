import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Is emri liste ekrani - saha ekiplerinin gunluk kullanacagi ana ekran
class WorkOrderListScreen extends ConsumerStatefulWidget {
  const WorkOrderListScreen({super.key});

  @override
  ConsumerState<WorkOrderListScreen> createState() => _WorkOrderListScreenState();
}

class _WorkOrderListScreenState extends ConsumerState<WorkOrderListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'İş emri ara...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                ),
              )
            : const Text('İş Emirleri'),
        actions: [
          // Arama butonu
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          // Filtre butonu
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              _showFilterSheet(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: API'den verileri yenile
        },
        child: _buildBody(context, isDark),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Yeni is emri olusturma sayfasina git
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    // Placeholder - API baglandiginda gercek liste gelecek
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: isDark ? AppColors.gray600 : AppColors.gray300,
            ),
            AppSpacing.verticalLg,
            Text(
              'İş Emirleri',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            AppSpacing.verticalSm,
            Text(
              'API bağlantısı kurulduğunda iş emirleriniz\nburada listelenecek',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
            ),
            AppSpacing.verticalXl,
            // Ornek kart - tasarimin nasil gorunecegini gosterir
            _SampleWorkOrderCard(isDark: isDark),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: AppSpacing.borderRadiusFull,
                    ),
                  ),
                ),
                Text(
                  'Filtrele',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppSpacing.verticalLg,
                Text(
                  'Durum',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.verticalSm,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(label: const Text('Beklemede'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Devam Ediyor'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Beklemede'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Tamamlandı'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('İptal'), selected: false, onSelected: (_) {}),
                  ],
                ),
                AppSpacing.verticalLg,
                Text(
                  'Öncelik',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.verticalSm,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(label: const Text('Düşük'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Normal'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Yüksek'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Acil'), selected: false, onSelected: (_) {}),
                    FilterChip(label: const Text('Kritik'), selected: false, onSelected: (_) {}),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Temizle'),
                      ),
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Uygula'),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalLg,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Ornek is emri karti - tasarim onizlemesi
class _SampleWorkOrderCard extends StatelessWidget {
  final bool isDark;

  const _SampleWorkOrderCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ust satir: Is no + oncelik
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'W-26-00142',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.horizontalXs,
                      Text(
                        'Yüksek',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.warningDark,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSm,

            // Is tipi + aciklama
            Text(
              'Altyapı Onarım',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            AppSpacing.verticalXs,
            Text(
              'Merkez Mah. Atatürk Cad. No:45',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            AppSpacing.verticalMd,

            // Alt satir: Durum + atanan + tarih
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.stepActive.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    'Devam Ediyor',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.stepActive,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14,
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
                AppSpacing.horizontalXs,
                Text(
                  '3',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                ),
                AppSpacing.horizontalMd,
                Text(
                  '2 gün önce',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
