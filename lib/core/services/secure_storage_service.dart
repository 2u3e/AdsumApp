import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage servisi - Token ve hassas veriler icin
/// iOS: Keychain, Android: EncryptedSharedPreferences
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Deger yaz
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Deger oku
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Deger sil
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Tum degerleri sil
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Anahtar var mi kontrol et
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
