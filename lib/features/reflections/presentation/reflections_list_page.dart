import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/reflection_repository.dart';
import '../data/reflection.dart';
import '../../../common/widgets/gmc_domain_selector.dart';
import '../../../common/widgets/empty_state.dart';
import 'widgets/document_source_selector.dart';
import 'reflection_from_document_page.dart';
import 'voice_note_flow_page.dart';

class ReflectionsListPage extends ConsumerStatefulWidget {
  const ReflectionsListPage({super.key});
  @override ConsumerState<ReflectionsListPage> createState() => _ReflectionsListPageState();
}

class _ReflectionsListPageState extends ConsumerState<ReflectionsListPage> {
  List<Reflection> _items = [];
  String _q = '';

  Future<void> _load() async {
    setState(()=>_items=[]);
    final repo = ref.read(reflectionRepositoryProvider);
    final list = _q.isEmpty ? await repo.list() : await repo.search(_q);
    setState(()=>_items=list);
  }

  @override void initState(){ super.initState(); _load(); }

  void _showCreateOptions() {
    // Capture the stable context from the widget
    final navigatorContext = context;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Reflection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // AI option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              title: const Text('From Document/Photo (AI)'),
              subtitle: const Text('Snap or upload, AI creates draft'),
              onTap: () {
                Navigator.pop(sheetContext);
                DocumentSourceSelector.show(
                  navigatorContext,
                  onTakePhoto: () {
                    Navigator.push(
                      navigatorContext,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'camera',
                        ),
                      ),
                    );
                  },
                  onChooseGallery: () {
                    Navigator.push(
                      navigatorContext,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'gallery',
                        ),
                      ),
                    );
                  },
                  onUploadDocument: () {
                    Navigator.push(
                      navigatorContext,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'document',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(),
            
            // Voice note option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.mic, color: Colors.red.shade700),
              ),
              title: const Text('From Voice Note'),
              subtitle: const Text('Record and transcribe'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  navigatorContext,
                  MaterialPageRoute(
                    builder: (context) => const VoiceNoteFlowPage(),
                  ),
                );
              },
            ),
            const Divider(),
            
            // Manual option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.grey),
              ),
              title: const Text('From Scratch'),
              subtitle: const Text('Type manually'),
              onTap: () {
                Navigator.pop(sheetContext);
                navigatorContext.go('/reflections/new');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflections'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Voice note FAB (quick access)
          FloatingActionButton(
            mini: true,
            heroTag: 'voice',
            backgroundColor: Colors.red.shade700,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceNoteFlowPage(),
                ),
              );
            },
            child: const Icon(Icons.mic, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Main add FAB
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showCreateOptions,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(children: [
        // AI Feature Banner
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade50,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.purple.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Improvements',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.purple.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap ✨ on any reflection to improve it with AI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.purple.shade400),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search'
            ),
            onChanged: (v){ _q=v; _load(); },
          ),
        ),
        Expanded(
          child: _items.isEmpty
            ? (_q.isNotEmpty 
                ? EmptySearchState(searchQuery: _q)
                : EmptyReflectionsState(
                    onCreateFirst: () => context.go('/reflections/new'),
                  ))
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (c,i){
                  final r=_items[i];
                  return ListTile(
                title: Text(r.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.tags.isNotEmpty) 
                      Text(r.tags.join(', ')),
                    if (r.domains != null && r.domains!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GmcDomainChips(domains: r.domains!, compact: true),
                    ],
                    if (r.score != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Score: ${(r.score! * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: r.hasRating 
                  ? Text(r.ratingDisplay, style: const TextStyle(fontSize: 16))
                  : null,
                onTap: ()=>context.go('/reflections/${r.id}'),
              );
            },
          ),
        ),
      ]),
    );
  }
}
