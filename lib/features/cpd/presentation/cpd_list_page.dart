import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cpd/data/cpd_repository.dart';
import '../../cpd/data/cpd_entry.dart';
import '../../../common/widgets/gmc_domain_selector.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/models/gmc_domain.dart';

class CpdListPage extends ConsumerStatefulWidget {
  const CpdListPage({super.key});
  @override ConsumerState<CpdListPage> createState() => _CpdListPageState();
}

class _CpdListPageState extends ConsumerState<CpdListPage> {
  List<CpdEntry> _items = [];
  List<CpdEntry> _filteredItems = [];
  int? _filterDomain;
  CpdType? _filterType;

  Future<void> _load() async { 
    final repo = ref.read(cpdRepositoryProvider);
    final list = await repo.list(); 
    setState(() {
      _items = list;
      _applyFilters();
    });
  }
  
  void _applyFilters() {
    var filtered = _items;
    
    // Filter by domain
    if (_filterDomain != null) {
      filtered = filtered.where((e) => e.domains.contains(_filterDomain)).toList();
    }
    
    // Filter by type
    if (_filterType != null) {
      filtered = filtered.where((e) => e.type == _filterType).toList();
    }
    
    _filteredItems = filtered;
  }
  
  double get _totalHours => _filteredItems.fold(0.0, (sum, e) => sum + e.hours);
  
  @override void initState(){ super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => context.go('/cpd/import'),
            tooltip: 'Import CPD',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>context.go('/cpd/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Domain filter
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: _filterDomain,
                        decoration: const InputDecoration(
                          labelText: 'Domain',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All', style: TextStyle(fontSize: 12, color: Colors.black)),
                          ),
                          ...GmcDomain.values.map((d) => DropdownMenuItem(
                            value: d.number,
                            child: Text(
                              '${d.number}: ${d.shortName}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterDomain = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Type filter
                    Expanded(
                      child: DropdownButtonFormField<CpdType?>(
                        value: _filterType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All', style: TextStyle(fontSize: 12, color: Colors.black)),
                          ),
                          ...CpdType.values.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterType = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Total hours display
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, 
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total: ${_totalHours.toStringAsFixed(1)} hours',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredItems.length} ${_filteredItems.length == 1 ? 'entry' : 'entries'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _items.isEmpty
              ? EmptyCpdState(
                  onCreateFirst: () => context.go('/cpd/new'),
                )
              : _filteredItems.isEmpty
                ? EmptyFilterState(
                    onClearFilters: () {
                      setState(() {
                        _filterDomain = null;
                        _filterType = null;
                        _applyFilters();
                      });
                    },
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (c,i){
                final e=_filteredItems[i];
                return ListTile(
                  title: Text(e.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.type.name} • ${e.hours}h • ${e.date.toString().substring(0, 10)}'),
                      if (e.domains.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        GmcDomainChips(domains: e.domains, compact: true),
                      ],
                      if (e.autoTags?.impact.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          e.autoTags!.impact,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  onTap: ()=>context.go('/cpd/${e.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
