import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Alt menü konumu tercihi: altta sabit (bottom) veya solda açılır (left drawer).
enum MenuPosition { bottom, left }

final menuPositionProvider =
    StateNotifierProvider<MenuPositionNotifier, MenuPosition>((ref) => MenuPositionNotifier());

class MenuPositionNotifier extends StateNotifier<MenuPosition> {
  MenuPositionNotifier() : super(MenuPosition.left) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(StorageKeys.menuPosition);
      if (v == 'bottom') state = MenuPosition.bottom;
    } catch (_) {}
  }

  Future<void> setPosition(MenuPosition p) async {
    state = p;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.menuPosition, p.name);
    } catch (_) {}
  }
}
