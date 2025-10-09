import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class KV {
  static const _boxName = 'metanoia_box';
  static Future<Box> _box() async => await Hive.openBox(_boxName);

  static Future<Map<String, dynamic>> getMap(String key) async {
    final box = await _box();
    final raw = box.get(key);
    if (raw is String) {
      try { return json.decode(raw) as Map<String, dynamic>; } catch (_) {}
    }
    return <String, dynamic>{};
  }

  static Future<void> setMap(String key, Map<String, dynamic> value) async {
    final box = await _box();
    await box.put(key, json.encode(value));
  }
}
