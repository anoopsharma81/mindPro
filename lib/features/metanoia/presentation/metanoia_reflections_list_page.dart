import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/metanoia_reflection_repository.dart';
import '../../../metanoia_reflection_schema.dart';
import 'metanoia_reflection_edit_page.dart';

class MetanoiaReflectionsListPage extends ConsumerStatefulWidget {
  const MetanoiaReflectionsListPage({super.key});

  @override
  ConsumerState<MetanoiaReflectionsListPage> createState() => _MetanoiaReflectionsListPageState();
}

class _MetanoiaReflectionsListPageState extends ConsumerState<MetanoiaReflectionsListPage> {
  List<MetanoiaReflection> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(metanoiaReflectionRepositoryProvider);
      final reflections = await repo.list();
      if (mounted) {
        setState(() {
          _reflections = reflections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reflections: $e')),
        );
      }
    }
  }

  Future<void> _deleteReflection(MetanoiaReflection reflection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reflection?'),
        content: Text('Are you sure you want to delete "${reflection.caseTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(metanoiaReflectionRepositoryProvider);
        await repo.remove(reflection.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reflection deleted')),
          );
          _loadReflections();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2F37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2F37),
        title: const Text('Metanoia Reflections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReflections,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reflections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 64,
                        color: const Color(0xFFF5F3F0).withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Metanoia reflections yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFFF5F3F0),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a structured clinical reflection',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFF5F3F0).withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReflections,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _reflections.length,
                    itemBuilder: (context, index) {
                      final reflection = _reflections[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black.withValues(alpha: 0.3),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.psychology,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            reflection.caseTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF5F3F0),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reflection.domain != null)
                                Text(
                                  reflection.domain!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFFF5F3F0).withValues(alpha: 0.7),
                                  ),
                                ),
                              Text(
                                reflection.caseDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFFF5F3F0).withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Created: ${_formatDate(reflection.createdAt)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFFF5F3F0).withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  context.go('/metanoia/${reflection.id}');
                                  break;
                                case 'delete':
                                  _deleteReflection(reflection);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            context.go('/metanoia/${reflection.id}');
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/metanoia/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Metanoia Reflection'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

