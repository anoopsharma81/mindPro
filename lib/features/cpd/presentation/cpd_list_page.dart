import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../cpd/data/cpd_repository.dart';
import '../../cpd/data/cpd_entry.dart';

class CpdListPage extends StatefulWidget {
  const CpdListPage({super.key});
  @override State<CpdListPage> createState() => _CpdListPageState();
}

class _CpdListPageState extends State<CpdListPage> {
  final _repo = CpdRepository();
  List<CpdEntry> _items = [];

  Future<void> _load() async { final list = await _repo.list(); setState(()=>_items=list); }
  @override void initState(){ super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CPD')),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>context.go('/cpd/new'),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (c,i){
          final e=_items[i];
          return ListTile(
            title: Text(e.title),
            subtitle: Text('${e.type.name} • ${e.hours}h'),
            onTap: ()=>context.go('/cpd/${e.id}'),
          );
        },
      ),
    );
  }
}
