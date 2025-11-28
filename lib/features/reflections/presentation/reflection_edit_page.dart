import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/reflection_repository.dart';
import '../data/reflection.dart';
import '../../../common/widgets/gmc_domain_selector.dart';
import '../../../common/widgets/phi_warning_dialog.dart';
import '../../../common/widgets/help_tooltip.dart';
// import '../../../common/widgets/voice_input_field.dart'; // Temporarily disabled until flutter pub get
import '../../../common/utils/phi_detector.dart';
import 'selfplay_runner.dart';
import 'reflection_templates.dart';
import 'widgets/audio_player_widget.dart';

/// Provider to hold initial reflection data for new reflections
class InitialReflectionData {
  final String? title;
  final String? what;
  final String? soWhat;
  final String? nowWhat;
  final List<String> tags;
  final List<int>? domains;
  
  InitialReflectionData({
    this.title,
    this.what,
    this.soWhat,
    this.nowWhat,
    this.tags = const [],
    this.domains,
  });
}

/// Simple holder for initial reflection data
class InitialReflectionDataHolder {
  InitialReflectionData? _data;
  
  InitialReflectionData? get data => _data;
  
  void setData(InitialReflectionData? data) {
    _data = data;
  }
  
  void clear() {
    _data = null;
  }
}

final initialReflectionDataHolder = InitialReflectionDataHolder();

final initialReflectionDataProvider = Provider<InitialReflectionData?>((ref) {
  return initialReflectionDataHolder.data;
});

class ReflectionEditPage extends ConsumerStatefulWidget {
  final String? id;
  const ReflectionEditPage({super.key, this.id});
  @override ConsumerState<ReflectionEditPage> createState() => _ReflectionEditPageState();
}

class _ReflectionEditPageState extends ConsumerState<ReflectionEditPage> {
  final _title = TextEditingController();
  final _reflection = TextEditingController();
  List<int> _selectedDomains = [];
  Reflection? _model;

  bool _hasLoaded = false;
  
  Future<void> _load() async {
    if (widget.id != null) {
      // Loading existing reflection
      final repo = ref.read(reflectionRepositoryProvider);
      final m = await repo.get(widget.id!);
      if (m != null){
        _model = m;
        _title.text = m.title;
        // Combine what, soWhat, and nowWhat into single reflection field
        final reflectionParts = <String>[];
        if (m.what.isNotEmpty) reflectionParts.add(m.what);
        if (m.soWhat.isNotEmpty) reflectionParts.add(m.soWhat);
        if (m.nowWhat.isNotEmpty) reflectionParts.add(m.nowWhat);
        _reflection.text = reflectionParts.join('\n\n');
        _selectedDomains = m.domains ?? [];
        setState((){});
      }
    } else {
      // New reflection - check for initial data
      final initialData = ref.read(initialReflectionDataProvider);
      if (initialData != null) {
        _title.text = initialData.title ?? '';
        // Combine what, soWhat, and nowWhat into single reflection field
        final reflectionParts = <String>[];
        if (initialData.what?.isNotEmpty == true) reflectionParts.add(initialData.what!);
        if (initialData.soWhat?.isNotEmpty == true) reflectionParts.add(initialData.soWhat!);
        if (initialData.nowWhat?.isNotEmpty == true) reflectionParts.add(initialData.nowWhat!);
        _reflection.text = reflectionParts.join('\n\n');
        _selectedDomains = initialData.domains ?? [];
        setState((){});
        
        // Clear the initial data after using it
        initialReflectionDataHolder.clear();
      }
    }
    _hasLoaded = true;
  }

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _load();
    }
  }

  Future<Reflection?> _save({bool navigateAway = true}) async {
    // Check for PHI before saving
    final combinedText = '${_title.text} ${_reflection.text}';
    
    if (mounted && PhiDetector.containsPhi(combinedText)) {
      final canContinue = await PhiWarningDialog.show(context, combinedText);
      if (!canContinue) return null; // User chose to review text
    }
    
    final repo = ref.read(reflectionRepositoryProvider);
    // Store the combined reflection text in the 'what' field
    // Keep soWhat and nowWhat empty for simplicity
    final reflectionText = _reflection.text.trim();

    Reflection? savedReflection;
    if (_model == null) {
      savedReflection = await repo.create(
        title: _title.text,
        what: reflectionText,
        soWhat: '', // Empty - all content in 'what'
        nowWhat: '', // Empty - all content in 'what'
        tags: const [], // No tags field in UI anymore
        domains: _selectedDomains.isEmpty ? null : _selectedDomains,
      );
      // Update _model so we can reload if needed
      _model = savedReflection;
    } else {
      final m = _model!.copyWith(
        title: _title.text,
        what: reflectionText,
        soWhat: '', // Empty - all content in 'what'
        nowWhat: '', // Empty - all content in 'what'
        tags: const [], // Preserve existing tags or empty
        domains: _selectedDomains.isEmpty ? null : _selectedDomains,
      );
      savedReflection = await repo.update(m.id, m);
      _model = savedReflection;
    }
    
    if (navigateAway && mounted) {
      context.go('/reflections');
    }
    
    return savedReflection;
  }

  Future<void> _delete() async {
    if (_model!=null){
      final repo = ref.read(reflectionRepositoryProvider);
      await repo.remove(_model!.id);
      if(mounted) context.go('/reflections');
    }
  }
  
  void _exitWithoutSaving() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Exit without saving?',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'Any unsaved changes will be lost.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/reflections'); // Exit page
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSelfPlay() async {
    // Validate we have content
    if (_title.text.trim().isEmpty || _reflection.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title and reflection text before improving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Save current state first (creates reflection if new, updates if existing)
    // Don't navigate away - we want to stay on this page
    final savedReflection = await _save(navigateAway: false);
    
    if (savedReflection == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save reflection for improvement'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    if (mounted) {
      // Navigate to self-play runner
      final improved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => SelfPlayRunner(
            reflectionId: savedReflection.id,
            reflection: savedReflection,
          ),
        ),
      );
      
      // Reload if improved
      if (improved == true && mounted) {
        await _load();
      }
    }
  }
  
  Future<void> _applyTemplate() async {
    final template = await TemplatePickerDialog.show(context);
    if (template != null && mounted) {
      setState(() {
        // Combine all template prompts into single reflection field
        final reflectionParts = <String>[];
        if (template.whatPrompt.isNotEmpty) reflectionParts.add(template.whatPrompt);
        if (template.soWhatPrompt.isNotEmpty) reflectionParts.add(template.soWhatPrompt);
        if (template.nowWhatPrompt.isNotEmpty) reflectionParts.add(template.nowWhatPrompt);
        _reflection.text = reflectionParts.join('\n\n');
        if (template.suggestedDomains.isNotEmpty) {
          _selectedDomains = List.from(template.suggestedDomains);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied "${template.title}" template')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    // Show button whenever there's content, not just when saved
    final canRunSelfPlay = _title.text.isNotEmpty && 
      _reflection.text.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? 'Edit Reflection' : 'New Reflection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reflections'),
        ),
        actions: [
          if (!isEdit)
            IconButton(
              onPressed: _applyTemplate,
              icon: const Icon(Icons.auto_stories),
              tooltip: 'Use template',
            ),
          HelpButton(
            title: 'Reflection Guide',
            content: 'Write your reflection in the text box below. You can include:\n\n'
                '• What happened (objective description)\n'
                '• Your thoughts and analysis\n'
                '• Learning points and significance\n'
                '• Actions for future practice\n\n'
                'Select GMC domains to show which areas of practice this reflection addresses.',
            tips: [
              'Avoid patient identifiers - use "a patient" or age ranges',
              'Focus on your learning, not the clinical details',
              'Be specific about actions you\'ll take',
            ],
          ),
          if (canRunSelfPlay)
            IconButton(
              onPressed: _openSelfPlay,
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Improve with Metanoia',
            ),
          if (isEdit)
            IconButton(
              onPressed: () => context.go('/reflections/${widget.id}/learning-loop'),
              icon: const Icon(Icons.psychology),
              tooltip: 'Learning Loop',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'exit':
                  _exitWithoutSaving();
                  break;
                case 'delete':
                  if (isEdit) _delete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'exit',
                child: Row(
                  children: [
                    const Icon(
                      Icons.exit_to_app,
                      size: 20,
                      color: Color(0xFFF5F3F0),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Exit without saving',
                      style: TextStyle(
                        color: Color(0xFFF5F3F0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEdit)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 12),
                      const Text(
                        'Delete reflection',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Audio player if audio exists
          if (_model?.audioUrl != null) ...[
            AudioPlayerWidget(
              audioUrl: _model!.audioUrl!,
              duration: _model!.audioDurationSeconds,
            ),
            const SizedBox(height: 16),
            // Transcription info
            if (_model!.transcriptionText != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voice Note • ${_model!.transcriptionMethod ?? "transcribed"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reflection,
            decoration: const InputDecoration(
              labelText: 'Your reflection',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 15,
            minLines: 10,
          ),
          const SizedBox(height: 16),
          GmcDomainSelector(
            selectedDomains: _selectedDomains,
            onChanged: (domains) {
              setState(() {
                _selectedDomains = domains;
              });
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
          if (canRunSelfPlay) ...[
            const SizedBox(height: 12),
            // AI Improvement Button
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openSelfPlay,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Improve with Metanoia',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16), // Bottom padding for scroll
        ],
        ),
      ),
    );
  }
}
