import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/reflection_repository.dart';
import '../data/reflection.dart';
import '../../../common/widgets/gmc_domain_selector.dart';
import '../../../common/widgets/empty_state.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>context.go('/reflections/new'),
        child: const Icon(Icons.add),
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
