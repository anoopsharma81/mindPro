import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import 'profile_model.dart';
import 'year_editor.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _gmcNumberController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  
  @override
  void dispose() {
    _displayNameController.dispose();
    _gmcNumberController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final currentProfile = await profileRepo.getProfile();
      final user = ref.read(currentUserProvider);
      
      if (user != null) {
        final profile = Profile(
          uid: user.uid,
          displayName: _displayNameController.text.trim(),
          gmcNumber: _gmcNumberController.text.trim(),
          defaultYear: currentProfile?.defaultYear ?? DateTime.now().year.toString(),
          createdAt: currentProfile?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await profileRepo.saveProfile(profile);
        
        setState(() => _isEditing = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final availableYears = ref.watch(availableYearsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile != null && !_isEditing) {
            _displayNameController.text = profile.displayName;
            _gmcNumberController.text = profile.gmcNumber;
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinician Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        
                        // Display name
                        TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 16),
                        
                        // GMC number
                        TextField(
                          controller: _gmcNumberController,
                          decoration: const InputDecoration(
                            labelText: 'GMC Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 16),
                        
                        // Default year
                        if (profile != null)
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Default Year'),
                            subtitle: Text(profile.defaultYear),
                            contentPadding: EdgeInsets.zero,
                          ),
                        
                        // Save/Cancel buttons
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _isEditing = false),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  child: _isSaving
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Years section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Appraisal Years',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _createNewYear(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        availableYears.when(
                          data: (years) => years.isEmpty
                            ? const Text('No years configured yet')
                            : Column(
                                children: years.map((year) => ListTile(
                                  leading: const Icon(Icons.event),
                                  title: Text(year),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _editYear(context, year),
                                  contentPadding: EdgeInsets.zero,
                                )).toList(),
                              ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error loading years'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  void _createNewYear(BuildContext context) {
    final currentYear = DateTime.now().year.toString();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => YearEditorPage(year: currentYear),
      ),
    );
  }
  
  void _editYear(BuildContext context, String year) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => YearEditorPage(year: year),
      ),
    );
  }
}

