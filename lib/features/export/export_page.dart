import 'package:flutter/material.dart';
import '../export/export_service.dart';
import '../reflections/data/reflection_repository.dart';
import '../cpd/data/cpd_repository.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});
  @override
  Widget build(BuildContext context) {
    final service = ExportService(ReflectionRepository(), CpdRepository());
    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await service.export();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exported')),
              );
            }
          },
          child: const Text('Export Markdown'),
        ),
      ),
    );
  }
}
