import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cpd/data/cpd_repository.dart';
import '../../cpd/data/cpd_entry.dart';

class CpdEditPage extends ConsumerStatefulWidget {
  final String? id;
  const CpdEditPage({super.key, this.id});
  @override ConsumerState<CpdEditPage> createState() => _CpdEditPageState();
}

class _CpdEditPageState extends ConsumerState<CpdEditPage> {
  CpdEntry? _model;
  CpdType _type = CpdType.other;
  final _title = TextEditingController();
  final _hours = TextEditingController();
  DateTime _date = DateTime.now();
  final _notes = TextEditingController();

  Future<void> _load() async {
    if (widget.id == null) return;
    final repo = ref.read(cpdRepositoryProvider);
    final m = await repo.get(widget.id!);
    if(m!=null){
      _model=m; _type=m.type; _title.text=m.title; _hours.text=m.hours.toString(); _date=m.date; _notes.text=m.notes??'';
      setState((){});
    }
  }
  @override void initState(){ super.initState(); _load(); }

  Future<void> _save() async {
    final repo = ref.read(cpdRepositoryProvider);
    final h = double.tryParse(_hours.text) ?? 0;
    if (_model == null) {
      await repo.create(type: _type, title: _title.text, hours: h, date: _date, notes: _notes.text.isEmpty? null:_notes.text);
    } else {
      final m = _model!.copyWith(type: _type, title: _title.text, hours: h, date: _date, notes: _notes.text);
      await repo.update(m.id, m);
    }
    if (mounted) context.go('/cpd');
  }

  Future<void> _delete() async {
    if(_model!=null){
      final repo = ref.read(cpdRepositoryProvider);
      await repo.remove(_model!.id);
      if(mounted) context.go('/cpd');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? 'Edit CPD' : 'New CPD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cpd'),
        ),
        actions:[ if(isEdit) IconButton(onPressed:_delete, icon: const Icon(Icons.delete)) ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButtonFormField<CpdType>(
            value: _type,
            items: CpdType.values.map((t)=>DropdownMenuItem(value:t, child: Text(t.name))).toList(),
            onChanged: (v){ if(v!=null) setState(()=>_type=v); },
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _hours, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hours')),
          const SizedBox(height: 12),
            Row(children:[
            Text(
              'Date: ${_date.toIso8601String().substring(0,10)}',
              style: const TextStyle(
                color: Color(0xFFF5F3F0),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: _date,
                );
                if(picked!=null) setState(()=>_date=picked);
              },
              child: const Text('Pick date'),
            )
          ]),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}
