import 'cpd_repository.dart';
import '../../reflections/data/reflection_repository.dart';

class LinkService {
  final CpdRepository cpdRepo;
  final ReflectionRepository reflRepo;
  LinkService(this.cpdRepo, this.reflRepo);

  Future<void> link(String cpdId, String reflectionId) async {
    final c = await cpdRepo.get(cpdId);
    final r = await reflRepo.get(reflectionId);
    if (c == null || r == null) return;
    final c2 = c.copyWith(linkedReflectionIds: {...c.linkedReflectionIds, reflectionId}.toList());
    final r2 = r.copyWith(linkedCpdIds: {...r.linkedCpdIds, cpdId}.toList());
    await cpdRepo.update(cpdId, c2);
    await reflRepo.update(reflectionId, r2);
  }

  Future<void> unlink(String cpdId, String reflectionId) async {
    final c = await cpdRepo.get(cpdId);
    final r = await reflRepo.get(reflectionId);
    if (c == null || r == null) return;
    final c2 = c.copyWith(linkedReflectionIds: c.linkedReflectionIds.where((x)=>x!=reflectionId).toList());
    final r2 = r.copyWith(linkedCpdIds: r.linkedCpdIds.where((x)=>x!=cpdId).toList());
    await cpdRepo.update(cpdId, c2);
    await reflRepo.update(reflectionId, r2);
  }
}
