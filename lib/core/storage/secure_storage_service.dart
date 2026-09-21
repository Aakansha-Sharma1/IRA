import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Contract for securely storing sensitive data (authentication tokens, session secrets)
abstract class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// FlutterSecureStorage implementation
class DefaultSecureStorageService implements SecureStorageService {
  final FlutterSecureStorage _storage;

  const DefaultSecureStorageService(this._storage);

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      AppLogger.error('SecureStorage write error for key: $key', e, st);
      throw StorageException(
        message: 'Failed to write to secure storage',
        details: e,
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      AppLogger.error('SecureStorage read error for key: $key', e, st);
      throw StorageException(
        message: 'Failed to read from secure storage',
        details: e,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      AppLogger.error('SecureStorage delete error for key: $key', e, st);
      throw StorageException(
        message: 'Failed to delete from secure storage',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      AppLogger.error('SecureStorage deleteAll error', e, st);
      throw StorageException(
        message: 'Failed to clear secure storage',
        details: e,
      );
    }
  }
}

/// Base secure storage instance provider
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
});

/// High-level secure storage service provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return DefaultSecureStorageService(storage);
});
