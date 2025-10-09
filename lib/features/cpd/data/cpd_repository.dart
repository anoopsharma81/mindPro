import 'package:uuid/uuid.dart';
import '../../../common/storage/storage.dart';
import 'cpd_entry.dart';

const _keyCpd = 'cpd';
const _uuid = Uuid();

class CpdRepository {
  Future<List<CpdEntry>> list() async {
    final map = await KV.getMap(_keyCpd); // id -> json
    return map.values
      .map((v) => CpdEntry.fromJson((v as Map).cast<String, dynamic>()))
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<CpdEntry?> get(String id) async {
    final map = await KV.getMap(_keyCpd);
    final j = map[id];
    return j == null ? null : CpdEntry.fromJson((j as Map).cast<String, dynamic>());
  }

  Future<CpdEntry> create({
    required CpdType type,
    required String title,
    required double hours,
    required DateTime date,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final c = CpdEntry(
      id: id,
      type: type,
      title: title,
      hours: hours,
      date: date,
      notes: notes,
      linkedReflectionIds: const [],
    );
    final map = await KV.getMap(_keyCpd);
    map[id] = c.toJson();
    await KV.setMap(_keyCpd, map);
    return c;
  }

  Future<CpdEntry?> update(String id, CpdEntry patch) async {
    final map = await KV.getMap(_keyCpd);
    if (!map.containsKey(id)) return null;
    map[id] = patch.toJson();
    await KV.setMap(_keyCpd, map);
    return await get(id);
  }

  Future<void> remove(String id) async {
    final map = await KV.getMap(_keyCpd);
    map.remove(id);
    await KV.setMap(_keyCpd, map);
  }
}
