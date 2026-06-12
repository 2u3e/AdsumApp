import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// Alt menü öğesi.
class AdsumNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const AdsumNavItem({required this.icon, required this.activeIcon, required this.label});
}

/// Modern, yüzen "genişleyen pill" alt navigasyon.
/// Aktif öğe ikon+etiket gösteren bir pill'e dönüşür; diğerleri yalnız ikon.
/// Öğe listesi dinamiktir (yetkiye göre değişebilir) — daha çok sayfaya da uyumlu.
class AdsumBottomNav extends StatelessWidget {
  final List<AdsumNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AdsumBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final surface = isDark ? AppColors.cardDark : Colors.white;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, (bottomInset > 0 ? bottomInset : 12)),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _NavSlot(
                item: items[i],
                selected: i == currentIndex,
                isDark: isDark,
                onTap: () {
                  if (i != currentIndex) HapticFeedback.selectionClick();
                  onTap(i);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Sol açılır menü (Drawer) içeriği — alt menüyle aynı öğeleri dikey listeler.
/// Menü konumu "Solda" seçiliyken kullanılır; ekran altını işlere bırakır.
class AdsumSideMenu extends StatelessWidget {
  final List<AdsumNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? userName;
  final String? userInitials;
  const AdsumSideMenu({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.userName,
    this.userInitials,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      width: 270,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Text(userInitials ?? 'AD',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName ?? 'ADSUM',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Belediye Yönetim',
                            style: TextStyle(
                                fontSize: 12, color: isDark ? AppColors.gray400 : AppColors.gray500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            for (var i = 0; i < items.length; i++)
              _SideItem(item: items[i], selected: i == currentIndex, onTap: () => onTap(i)),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Text('Sürüm ${AppConstants.appVersion}',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.gray500 : AppColors.gray400)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final AdsumNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _SideItem({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(selected ? item.activeIcon : item.icon,
                    size: 22, color: selected ? AppColors.primary : (isDark ? AppColors.gray400 : AppColors.gray600)),
                const SizedBox(width: 14),
                Text(item.label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primary : null,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  final AdsumNavItem item;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _NavSlot({required this.item, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.gray400 : AppColors.gray500;
    // Seçili öğe genişler (etiketi gösterir), diğerleri daralır.
    return Expanded(
      flex: selected ? 0 : 1,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 46,
          margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 0),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 23,
                color: selected ? AppColors.primary : muted,
              ),
              // Seçiliyken etiket animasyonlu açılır.
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
