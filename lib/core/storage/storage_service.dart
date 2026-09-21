import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Contract for standard key-value storage (non-sensitive preferences only)
abstract class StorageService {
  Future<void> init();
  Future<bool> setString(String key, String value);
  String? getString(String key);
  Future<bool> setBool(String key, bool value);
  bool? getBool(String key);
  Future<bool> setInt(String key, int value);
  int? getInt(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
}

/// SharedPreferences implementation of StorageService
class SharedPreferencesStorageService implements StorageService {
  final SharedPreferences _prefs;

  SharedPreferencesStorageService(this._prefs);

  @override
  Future<void> init() async {
    // Initialized prior to injection
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e, st) {
      AppLogger.error('Error writing string to storage: $key', e, st);
      throw StorageException(message: 'Failed to write string for key: $key', details: e);
    }
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e, st) {
      AppLogger.error('Error writing bool to storage: $key', e, st);
      throw StorageException(message: 'Failed to write bool for key: $key', details: e);
    }
  }

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e, st) {
      AppLogger.error('Error writing int to storage: $key', e, st);
      throw StorageException(message: 'Failed to write int for key: $key', details: e);
    }
  }

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e, st) {
      AppLogger.error('Error removing key from storage: $key', e, st);
      throw StorageException(message: 'Failed to remove key: $key', details: e);
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e, st) {
      AppLogger.error('Error clearing storage', e, st);
      throw StorageException(message: 'Failed to clear storage', details: e);
    }
  }
}

/// Provider for SharedPreferences instance (overridden at startup in ProviderScope)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

/// Provider for general storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesStorageService(prefs);
});
