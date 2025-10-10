import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'profile_model.dart';

class YearEditorPage extends ConsumerStatefulWidget {
  final String year;
  
  const YearEditorPage({super.key, required this.year});
  
  @override
  ConsumerState<YearEditorPage> createState() => _YearEditorPageState();
}

class _YearEditorPageState extends ConsumerState<YearEditorPage> {
  final _specialtyController = TextEditingController();
  final _orgController = TextEditingController();
  final _appraiserNameController = TextEditingController();
  final _appraiserRoleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _appraisalDate;
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadYearConfig();
  }
  
  @override
  void dispose() {
    _specialtyController.dispose();
    _orgController.dispose();
    _appraiserNameController.dispose();
    _appraiserRoleController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadYearConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(profileRepositoryProvider);
      final config = await repo.getYearConfig(widget.year);
      
      if (config != null) {
        _specialtyController.text = config.specialty;
        _orgController.text = config.org;
        _appraiserNameController.text = config.appraiserName;
        _appraiserRoleController.text = config.appraiserRole;
        _locationController.text = config.location;
        _appraisalDate = config.appraisalDate;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _save() async {
    setState(() => _isSaving = true);
    
    try {
      final repo = ref.read(profileRepositoryProvider);
      final yearConfig = YearConfig(
        year: widget.year,
        specialty: _specialtyController.text.trim(),
        org: _orgController.text.trim(),
        appraiserName: _appraiserNameController.text.trim(),
        appraiserRole: _appraiserRoleController.text.trim(),
        appraisalDate: _appraisalDate,
        location: _locationController.text.trim(),
      );
      
      await repo.saveYearConfig(yearConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Year configuration saved')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.year} Configuration')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year} Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Appraisal Year ${widget.year}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            
            // Specialty
            TextField(
              controller: _specialtyController,
              decoration: const InputDecoration(
                labelText: 'Specialty',
                border: OutlineInputBorder(),
                helperText: 'e.g., General Practice, Emergency Medicine',
              ),
            ),
            const SizedBox(height: 16),
            
            // Organisation
            TextField(
              controller: _orgController,
              decoration: const InputDecoration(
                labelText: 'Organisation / Trust',
                border: OutlineInputBorder(),
                helperText: 'e.g., NHS Trust name',
              ),
            ),
            const SizedBox(height: 16),
            
            // Appraiser name
            TextField(
              controller: _appraiserNameController,
              decoration: const InputDecoration(
                labelText: 'Appraiser Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Appraiser role
            TextField(
              controller: _appraiserRoleController,
              decoration: const InputDecoration(
                labelText: 'Appraiser Role',
                border: OutlineInputBorder(),
                helperText: 'e.g., Consultant, Educational Supervisor',
              ),
            ),
            const SizedBox(height: 16),
            
            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                helperText: 'e.g., Hospital name, City',
              ),
            ),
            const SizedBox(height: 16),
            
            // Appraisal date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Appraisal Date'),
              subtitle: Text(_appraisalDate?.toString().substring(0, 10) ?? 'Not set'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _appraisalDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _appraisalDate = picked);
                }
              },
            ),
            const SizedBox(height: 32),
            
            // Save button
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }
}

