import 'package:flutter/material.dart';
import '../data/reflection_repository.dart';
import '../data/reflection.dart';

class ReflectionEditPage extends StatefulWidget {
  final String? id;
  const ReflectionEditPage({super.key, this.id});
  @override State<ReflectionEditPage> createState() => _ReflectionEditPageState();
}

class _ReflectionEditPageState extends State<ReflectionEditPage> {
  final _repo = ReflectionRepository();
  final _title = TextEditingController();
  final _what = TextEditingController();
  final _soWhat = TextEditingController();
  final _nowWhat = TextEditingController();
  final _tags = TextEditingController();
  Reflection? _model;

  Future<void> _load() async {
    if (widget.id == null) return;
    final m = await _repo.get(widget.id!);
    if (m != null){
      _model = m;
      _title.text = m.title;
      _what.text = m.what;
      _soWhat.text = m.soWhat;
      _nowWhat.text = m.nowWhat;
      _tags.text = m.tags.join(', ');
      setState((){});
    }
  }

  @override void initState(){ super.initState(); _load(); }

  Future<void> _save() async {
    final tags = _tags.text.split(',')
      .map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList();

    if (_model == null) {
      await _repo.create(
        title: _title.text,
        what: _what.text,
        soWhat: _soWhat.text,
        nowWhat: _nowWhat.text,
        tags: tags,
      );
    } else {
      final m = _model!.copyWith(
        title: _title.text,
        what: _what.text,
        soWhat: _soWhat.text,
        nowWhat: _nowWhat.text,
        tags: tags,
      );
      await _repo.update(m.id, m);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (_model!=null){
      await _repo.remove(_model!.id);
      if(mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? 'Edit Reflection' : 'New Reflection'),
        actions: [ if (isEdit) IconButton(onPressed: _delete, icon: const Icon(Icons.delete)) ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _what, decoration: const InputDecoration(labelText: 'What')),
          const SizedBox(height: 12),
          TextField(controller: _soWhat, decoration: const InputDecoration(labelText: 'So What')),
          const SizedBox(height: 12),
          TextField(controller: _nowWhat, decoration: const InputDecoration(labelText: 'Now What')),
          const SizedBox(height: 12),
          TextField(controller: _tags, decoration: const InputDecoration(labelText: 'Tags (comma separated)')),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}
