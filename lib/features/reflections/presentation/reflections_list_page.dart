import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/reflection_repository.dart';
import '../data/reflection.dart';
import '../../../common/widgets/gmc_domain_selector.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'voice_note_flow_page.dart';
import 'widgets/document_source_selector.dart';
import 'reflection_from_document_page.dart';

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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5F3F0),
              ),
            ),
            const SizedBox(height: 16),
            
            // Manual option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, color: Colors.blue.shade700),
              ),
              title: const Text(
                'Write Manually',
                style: TextStyle(
                  color: Color(0xFFF5F3F0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Type your reflection',
                style: TextStyle(
                  color: const Color(0xFFF5F3F0).withValues(alpha: 0.7),
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.go('/reflections/new');
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
              title: const Text(
                'Record Voice Note',
                style: TextStyle(
                  color: Color(0xFFF5F3F0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Speak and transcribe',
                style: TextStyle(
                  color: const Color(0xFFF5F3F0).withValues(alpha: 0.7),
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceNoteFlowPage(),
                  ),
                );
              },
            ),
            const Divider(),
            
            // AI Document extraction option
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
              title: const Text(
                'Extract from Document',
                style: TextStyle(
                  color: Color(0xFFF5F3F0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'AI extracts from any file type',
                style: TextStyle(
                  color: const Color(0xFFF5F3F0).withValues(alpha: 0.7),
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                DocumentSourceSelector.show(
                  context,
                  onTakePhoto: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'camera',
                        ),
                      ),
                    );
                  },
                  onChooseGallery: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'gallery',
                        ),
                      ),
                    );
                  },
                  onUploadDocument: () {
                    Navigator.push(
                      context,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateOptions,
            tooltip: 'Create Reflection',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
      body: Column(children: [
        // AI Feature Banner
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tap ✨ button on any reflection to improve it with Metanoia',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
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
                title: Text(
                  r.title,
                  style: const TextStyle(color: Color(0xFFF5F3F0)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.tags.isNotEmpty) 
                      Text(
                        r.tags.join(', '),
                        style: TextStyle(color: const Color(0xFFF5F3F0).withOpacity(0.8)),
                      ),
                    if (r.domains != null && r.domains!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      GmcDomainChips(domains: r.domains!, compact: true),
                    ],
                    if (r.score != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Score: ${(r.score! * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF5F3F0),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: r.hasRating 
                  ? Text(
                      r.ratingDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF5F3F0),
                      ),
                    )
                  : null,
                onTap: ()=>context.go('/reflections/${r.id}'),
              );
            },
          ),
        ),
      ]),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
