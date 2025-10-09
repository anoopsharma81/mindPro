import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/reflection_repository.dart';
import '../data/reflection.dart';

class ReflectionsListPage extends StatefulWidget {
  const ReflectionsListPage({super.key});
  @override State<ReflectionsListPage> createState() => _ReflectionsListPageState();
}

class _ReflectionsListPageState extends State<ReflectionsListPage> {
  final _repo = ReflectionRepository();
  List<Reflection> _items = [];
  String _q = '';

  Future<void> _load() async {
    setState(()=>_items=[]);
    final list = _q.isEmpty ? await _repo.list() : await _repo.search(_q);
    setState(()=>_items=list);
  }

  @override void initState(){ super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflections')),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>context.go('/reflections/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search'
            ),
            onChanged: (v){ _q=v; _load(); },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (c,i){
              final r=_items[i];
              return ListTile(
                title: Text(r.title),
                subtitle: Text(r.tags.join(', ')),
                onTap: ()=>context.go('/reflections/${r.id}'),
              );
            },
          ),
        ),
      ]),
    );
  }
}
