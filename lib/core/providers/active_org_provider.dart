import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/membership.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/storage_keys.dart';

/// Aktif birim id'si. Web header'daki birim secicinin mobil muadili.
/// Kullanici coklu birimdeyse buradan secer; secim SharedPreferences'ta saklanir,
/// login'e donmeden degisir. Varsayilan: kalici secim gecerliyse o, yoksa ilk uyelik.
final activeOrganizationProvider =
    NotifierProvider<ActiveOrganizationNotifier, String?>(ActiveOrganizationNotifier.new);

class ActiveOrganizationNotifier extends Notifier<String?> {
  @override
  String? build() {
    final memberships = ref.watch(
      authStateProvider.select((s) => s.value?.user?.memberships ?? const <Membership>[]),
    );
    if (memberships.isEmpty) return null;

    // Mevcut state hâlâ geçerli bir üyelikse koru.
    final current = stateOrNull;
    if (current != null && memberships.any((m) => m.organizationId == current)) {
      return current;
    }
    // Aksi halde ilk üyelik (kalıcı seçim _restore ile düzeltilir).
    _restorePersisted(memberships);
    return memberships.first.organizationId;
  }

  Future<void> _restorePersisted(List<Membership> memberships) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(StorageKeys.activeOrganizationId);
      if (saved != null && memberships.any((m) => m.organizationId == saved) && saved != state) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> setActive(String organizationId) async {
    state = organizationId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.activeOrganizationId, organizationId);
    } catch (_) {}
  }
}

/// Aktif membership nesnesi (id'den çözümlenir).
final activeMembershipProvider = Provider<Membership?>((ref) {
  final activeId = ref.watch(activeOrganizationProvider);
  final memberships = ref.watch(
    authStateProvider.select((s) => s.value?.user?.memberships ?? const <Membership>[]),
  );
  if (activeId == null) return memberships.isEmpty ? null : memberships.first;
  for (final m in memberships) {
    if (m.organizationId == activeId) return m;
  }
  return memberships.isEmpty ? null : memberships.first;
});
