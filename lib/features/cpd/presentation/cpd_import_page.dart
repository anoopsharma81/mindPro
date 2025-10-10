import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/cpd_repository.dart';
import '../data/cpd_entry.dart';

/// CPD Import page for importing from various sources
class CpdImportPage extends ConsumerStatefulWidget {
  const CpdImportPage({super.key});

  @override
  ConsumerState<CpdImportPage> createState() => _CpdImportPageState();
}

class _CpdImportPageState extends ConsumerState<CpdImportPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _importFromPhoto() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null && mounted) {
        // In a full implementation, this would use OCR to extract text
        // For now, we'll show a dialog to manually enter details
        await _showManualEntryDialog(
          context,
          suggestedTitle: 'Certificate from photo',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        // In a full implementation, this would use OCR to extract text
        // For now, we'll show a dialog to manually enter details
        await _showManualEntryDialog(
          context,
          suggestedTitle: 'Certificate from gallery',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _importFromCSV() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV import coming soon! Export from your LMS and import here.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _importFromCalendar() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calendar sync coming soon! Your training events will auto-import.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showManualEntryDialog(
    BuildContext context, {
    String? suggestedTitle,
  }) async {
    final titleController = TextEditingController(text: suggestedTitle ?? '');
    final hoursController = TextEditingController(text: '1.0');
    CpdType selectedType = CpdType.course;
    DateTime selectedDate = DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add CPD Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CpdType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: CpdType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hoursController,
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(selectedDate.toString().substring(0, 10)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      // Create CPD entry
      final repo = ref.read(cpdRepositoryProvider);
      final hours = double.tryParse(hoursController.text) ?? 1.0;

      await repo.create(
        type: selectedType,
        title: titleController.text,
        hours: hours,
        date: selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CPD entry added')),
        );
        context.go('/cpd');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import CPD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cpd'),
        ),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Import CPD from multiple sources',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save time by importing CPD activities from certificates, '
                          'calendars, or CSV files instead of manual entry.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Photo/Certificate import
                _ImportOptionCard(
                  icon: Icons.camera_alt,
                  title: 'Photo/Certificate',
                  description: 'Scan a certificate with your camera',
                  color: Colors.blue,
                  onTap: _importFromPhoto,
                ),
                const SizedBox(height: 12),

                _ImportOptionCard(
                  icon: Icons.photo_library,
                  title: 'From Gallery',
                  description: 'Choose an existing photo or PDF',
                  color: Colors.purple,
                  onTap: _importFromGallery,
                ),
                const SizedBox(height: 12),

                _ImportOptionCard(
                  icon: Icons.upload_file,
                  title: 'CSV Import',
                  description: 'Import from BMJ Learning, e-LfH, or Excel',
                  color: Colors.green,
                  onTap: _importFromCSV,
                  badge: 'Coming Soon',
                ),
                const SizedBox(height: 12),

                _ImportOptionCard(
                  icon: Icons.calendar_today,
                  title: 'Calendar Sync',
                  description: 'Auto-import training events from calendar',
                  color: Colors.orange,
                  onTap: _importFromCalendar,
                  badge: 'Coming Soon',
                ),

                const SizedBox(height: 32),

                // Manual entry fallback
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Manual Entry'),
                    subtitle: const Text('Add CPD the traditional way'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/cpd/new'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ImportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _ImportOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

