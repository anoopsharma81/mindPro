import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../reflections/data/reflection_repository.dart';
import '../cpd/data/cpd_repository.dart';

class ExportService {
  final ReflectionRepository reflRepo;
  final CpdRepository cpdRepo;
  ExportService(this.reflRepo, this.cpdRepo);

  Future<String> buildMarkdown() async {
    final rs = await reflRepo.list();
    final cs = await cpdRepo.list();
    final buf = StringBuffer('# Metanoia Export\n\n');
    buf.writeln('## Reflections');
    for (final r in rs) {
      buf.writeln('- **${r.title}** (${r.createdAt.toIso8601String()})');
      buf.writeln('  - What: ${r.what}');
      buf.writeln('  - So What: ${r.soWhat}');
      buf.writeln('  - Now What: ${r.nowWhat}');
      if (r.tags.isNotEmpty) buf.writeln('  - Tags: ${r.tags.join(', ')}');
      if (r.linkedCpdIds.isNotEmpty) buf.writeln('  - Linked CPD: ${r.linkedCpdIds.join(', ')}');
      buf.writeln('');
    }
    buf.writeln('## CPD');
    for (final c in cs) {
      buf.writeln('- **${c.title}** (${c.type.name}) ${c.hours}h @ ${c.date.toIso8601String()}');
      if ((c.notes ?? '').isNotEmpty) buf.writeln('  - Notes: ${c.notes}');
      if (c.linkedReflectionIds.isNotEmpty) buf.writeln('  - Linked Reflections: ${c.linkedReflectionIds.join(', ')}');
      buf.writeln('');
    }
    return buf.toString();
  }

  Future<void> export() async {
    final md = await buildMarkdown();
    final data = Uint8List.fromList(md.codeUnits);
    const name = 'metanoia_export.md';
    if (kIsWeb) {
      await FileSaver.instance.saveFile(
        name: name,
        bytes: data,
        fileExtension: 'md',
        mimeType: MimeType.text,
      );
    } else {
      await Share.shareXFiles([XFile.fromData(data, name: name, mimeType: 'text/markdown')]);
    }
  }
}
