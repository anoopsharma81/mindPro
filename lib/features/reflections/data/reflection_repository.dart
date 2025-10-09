import 'package:uuid/uuid.dart';
import '../../../common/storage/storage.dart';
import 'reflection.dart';

const _key = 'reflections';
const _uuid = Uuid();

class ReflectionRepository {
  Future<List<Reflection>> list() async {
    final map = await KV.getMap(_key); // id -> json
    return map.values
      .map((v) => Reflection.fromJson((v as Map).cast<String, dynamic>()))
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Reflection?> get(String id) async {
    final map = await KV.getMap(_key);
    final j = map[id];
    return j == null ? null : Reflection.fromJson((j as Map).cast<String, dynamic>());
  }

  Future<Reflection> create({
    required String title,
    required String what,
    required String soWhat,
    required String nowWhat,
    List<String> tags = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final r = Reflection(
      id: id,
      title: title,
      what: what,
      soWhat: soWhat,
      nowWhat: nowWhat,
      tags: tags,
      createdAt: now,
      updatedAt: now,
      linkedCpdIds: const [],
    );
    final map = await KV.getMap(_key);
    map[id] = r.toJson();
    await KV.setMap(_key, map);
    return r;
  }

  Future<Reflection?> update(String id, Reflection patch) async {
    final map = await KV.getMap(_key);
    if (!map.containsKey(id)) return null;
    map[id] = patch.copyWith(updatedAt: DateTime.now()).toJson();
    await KV.setMap(_key, map);
    return await get(id);
  }

  Future<void> remove(String id) async {
    final map = await KV.getMap(_key);
    map.remove(id);
    await KV.setMap(_key, map);
  }

  Future<List<Reflection>> search(String q) async {
    final s = q.trim().toLowerCase();
    final all = await list();
    if (s.isEmpty) return all;
    return all.where((r) =>
      r.title.toLowerCase().contains(s) ||
      r.what.toLowerCase().contains(s) ||
      r.soWhat.toLowerCase().contains(s) ||
      r.nowWhat.toLowerCase().contains(s) ||
      r.tags.any((t) => t.toLowerCase().contains(s))
    ).toList();
  }
}
