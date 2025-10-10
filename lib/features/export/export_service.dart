import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../reflections/data/reflection_repository.dart';
import '../cpd/data/cpd_repository.dart';
import '../profile/profile_model.dart';
import '../../common/models/gmc_domain.dart';

class ExportService {
  final ReflectionRepository reflRepo;
  final CpdRepository cpdRepo;
  final Profile? profile;
  final YearConfig? yearConfig;
  final String year;
  
  ExportService(
    this.reflRepo, 
    this.cpdRepo, {
    this.profile,
    this.yearConfig,
    required this.year,
  });

  Future<String> buildMarkdown() async {
    final rs = await reflRepo.list();
    final cs = await cpdRepo.list();
    final buf = StringBuffer();
    
    // Header
    buf.writeln('# NHS Appraisal Portfolio Export');
    buf.writeln('## Metanoia - Reflective Practice Assistant\n');
    
    // Profile section
    if (profile != null) {
      buf.writeln('## Clinician Profile\n');
      buf.writeln('- **Name**: ${profile!.displayName}');
      buf.writeln('- **GMC Number**: ${profile!.gmcNumber}');
      buf.writeln('- **Year**: $year\n');
    }
    
    // Year configuration
    if (yearConfig != null) {
      buf.writeln('## Appraisal Details\n');
      if (yearConfig!.specialty.isNotEmpty) buf.writeln('- **Specialty**: ${yearConfig!.specialty}');
      if (yearConfig!.org.isNotEmpty) buf.writeln('- **Organisation**: ${yearConfig!.org}');
      if (yearConfig!.appraiserName.isNotEmpty) buf.writeln('- **Appraiser**: ${yearConfig!.appraiserName}');
      if (yearConfig!.appraiserRole.isNotEmpty) buf.writeln('- **Appraiser Role**: ${yearConfig!.appraiserRole}');
      if (yearConfig!.appraisalDate != null) {
        buf.writeln('- **Appraisal Date**: ${yearConfig!.appraisalDate!.toString().substring(0, 10)}');
      }
      if (yearConfig!.location.isNotEmpty) buf.writeln('- **Location**: ${yearConfig!.location}');
      buf.writeln('');
    }
    
    buf.writeln('---\n');
    
    // Reflections by domain
    buf.writeln('## Reflections\n');
    if (rs.isEmpty) {
      buf.writeln('*No reflections recorded for this year.*\n');
    } else {
      // Group by GMC domain
      for (final domain in GmcDomain.values) {
        final domainReflections = rs.where((r) => 
          r.domains != null && r.domains!.contains(domain.number)
        ).toList();
        
        if (domainReflections.isNotEmpty) {
          buf.writeln('### GMC Domain ${domain.number}: ${domain.title}\n');
          for (final r in domainReflections) {
            buf.writeln('#### ${r.title}');
            buf.writeln('*Created: ${r.createdAt.toString().substring(0, 10)}*\n');
            buf.writeln('**What happened:**');
            buf.writeln('${r.what}\n');
            buf.writeln('**So what (analysis):**');
            buf.writeln('${r.soWhat}\n');
            buf.writeln('**Now what (action):**');
            buf.writeln('${r.nowWhat}\n');
            if (r.tags.isNotEmpty) buf.writeln('*Tags: ${r.tags.join(', ')}*');
            if (r.score != null) buf.writeln('*Quality Score: ${(r.score! * 100).toStringAsFixed(0)}%*');
            if (r.rating != null) buf.writeln('*User Rating: ${r.ratingDisplay}*');
            buf.writeln('');
          }
        }
      }
      
      // Untagged reflections
      final untagged = rs.where((r) => r.domains == null || r.domains!.isEmpty).toList();
      if (untagged.isNotEmpty) {
        buf.writeln('### Other Reflections\n');
        for (final r in untagged) {
          buf.writeln('#### ${r.title}');
          buf.writeln('*Created: ${r.createdAt.toString().substring(0, 10)}*\n');
          buf.writeln('**What:** ${r.what}\n');
          buf.writeln('**So What:** ${r.soWhat}\n');
          buf.writeln('**Now What:** ${r.nowWhat}\n');
          if (r.tags.isNotEmpty) buf.writeln('*Tags: ${r.tags.join(', ')}*\n');
        }
      }
    }
    
    buf.writeln('---\n');
    
    // CPD by domain
    buf.writeln('## Continuing Professional Development (CPD)\n');
    if (cs.isEmpty) {
      buf.writeln('*No CPD entries recorded for this year.*\n');
    } else {
      final totalHours = cs.fold(0.0, (sum, c) => sum + c.hours);
      buf.writeln('**Total CPD Hours**: ${totalHours.toStringAsFixed(1)}h\n');
      
      // Group by GMC domain
      for (final domain in GmcDomain.values) {
        final domainCpd = cs.where((c) => c.domains.contains(domain.number)).toList();
        
        if (domainCpd.isNotEmpty) {
          final domainHours = domainCpd.fold(0.0, (sum, c) => sum + c.hours);
          buf.writeln('### GMC Domain ${domain.number}: ${domain.title}');
          buf.writeln('*Total: ${domainHours.toStringAsFixed(1)}h*\n');
          
          for (final c in domainCpd) {
            buf.writeln('- **${c.title}** (${c.type.name}) - ${c.hours}h');
            buf.writeln('  - Date: ${c.date.toString().substring(0, 10)}');
            if (c.notes?.isNotEmpty == true) buf.writeln('  - Notes: ${c.notes}');
            if (c.autoTags?.impact.isNotEmpty == true) buf.writeln('  - Impact: ${c.autoTags!.impact}');
            buf.writeln('');
          }
        }
      }
      
      // Untagged CPD
      final untaggedCpd = cs.where((c) => c.domains.isEmpty).toList();
      if (untaggedCpd.isNotEmpty) {
        buf.writeln('### Other CPD Activities\n');
        for (final c in untaggedCpd) {
          buf.writeln('- **${c.title}** (${c.type.name}) - ${c.hours}h @ ${c.date.toString().substring(0, 10)}');
          if (c.notes?.isNotEmpty == true) buf.writeln('  - ${c.notes}');
          buf.writeln('');
        }
      }
    }
    
    buf.writeln('---\n');
    buf.writeln('*Generated by Metanoia on ${DateTime.now().toString().substring(0, 16)}*');
    
    return buf.toString();
  }

  Future<void> export() async {
    final md = await buildMarkdown();
    final data = Uint8List.fromList(md.codeUnits);
    final name = 'metanoia_appraisal_$year.md';
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
