import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// Typed Hive wrapper for lightweight key-value persistence.
///
/// Box names follow a strict naming convention: `nexora_<purpose>`.
/// This prevents collision in shared Hive environments.
@singleton
class HiveStorage {
  static const _prefBox = 'nexora_prefs';
  static const _cacheBox = 'nexora_cache';

  Future<void> init() async {
    await Hive.openBox(_prefBox);
    await Hive.openBox(_cacheBox);
  }

  // ─── Preferences ──────────────────────────────────────────────────────────
  Future<void> savePref<T>(String key, T value) async {
    final box = Hive.box(_prefBox);
    await box.put(key, value);
  }

  T? getPref<T>(String key) {
    final box = Hive.box(_prefBox);
    return box.get(key) as T?;
  }

  Future<void> deletePref(String key) => Hive.box(_prefBox).delete(key);

  // ─── JSON Cache ────────────────────────────────────────────────────────────
  Future<void> cacheJson(String key, Map<String, dynamic> json) async {
    final box = Hive.box(_cacheBox);
    await box.put(key, json);
  }

  Map<String, dynamic>? getCachedJson(String key) {
    final box = Hive.box(_cacheBox);
    final value = box.get(key);
    return value != null ? Map<String, dynamic>.from(value as Map) : null;
  }

  Future<void> invalidateCache(String key) => Hive.box(_cacheBox).delete(key);

  Future<void> clearCache() => Hive.box(_cacheBox).clear();
}
