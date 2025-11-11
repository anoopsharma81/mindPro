import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../export/export_service.dart';
import '../reflections/data/reflection_repository.dart';
import '../cpd/data/cpd_repository.dart';
import '../auth/auth_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class ExportPage extends ConsumerWidget {
  const ExportPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflectionRepo = ref.watch(reflectionRepositoryProvider);
    final cpdRepo = ref.watch(cpdRepositoryProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final yearConfigAsync = ref.watch(currentYearConfigProvider);
    final year = ref.watch(selectedYearProvider);
    
    final service = ExportService(
      reflectionRepo,
      cpdRepo,
      profile: profileAsync.value,
      yearConfig: yearConfigAsync.value,
      year: year,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
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
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
