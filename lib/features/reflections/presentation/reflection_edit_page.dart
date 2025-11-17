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

class ReflectionEditPage extends ConsumerStatefulWidget {
  final String? id;
  const ReflectionEditPage({super.key, this.id});
  @override ConsumerState<ReflectionEditPage> createState() => _ReflectionEditPageState();
}

class _ReflectionEditPageState extends ConsumerState<ReflectionEditPage> {
  final _title = TextEditingController();
  final _what = TextEditingController();
  final _soWhat = TextEditingController();
  final _nowWhat = TextEditingController();
  final _tags = TextEditingController();
  List<int> _selectedDomains = [];
  Reflection? _model;

  Future<void> _load() async {
    if (widget.id == null) return;
    final repo = ref.read(reflectionRepositoryProvider);
    final m = await repo.get(widget.id!);
    if (m != null){
      _model = m;
      _title.text = m.title;
      _what.text = m.what;
      _soWhat.text = m.soWhat;
      _nowWhat.text = m.nowWhat;
      _tags.text = m.tags.join(', ');
      _selectedDomains = m.domains ?? [];
      setState((){});
    }
  }

  @override void initState(){ super.initState(); _load(); }

  Future<void> _save() async {
    // Check for PHI before saving
    final combinedText = '${_title.text} ${_what.text} ${_soWhat.text} ${_nowWhat.text}';
    
    if (mounted && PhiDetector.containsPhi(combinedText)) {
      final canContinue = await PhiWarningDialog.show(context, combinedText);
      if (!canContinue) return; // User chose to review text
    }
    
    final repo = ref.read(reflectionRepositoryProvider);
    final tags = _tags.text.split(',')
      .map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList();

    if (_model == null) {
      await repo.create(
        title: _title.text,
        what: _what.text,
        soWhat: _soWhat.text,
        nowWhat: _nowWhat.text,
        tags: tags,
        domains: _selectedDomains.isEmpty ? null : _selectedDomains,
      );
    } else {
      final m = _model!.copyWith(
        title: _title.text,
        what: _what.text,
        soWhat: _soWhat.text,
        nowWhat: _nowWhat.text,
        tags: tags,
        domains: _selectedDomains.isEmpty ? null : _selectedDomains,
      );
      await repo.update(m.id, m);
    }
    if (mounted) context.go('/reflections');
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
    // Save current state first
    await _save();
    
    // Reload to get the saved reflection
    if (widget.id != null) {
      final repo = ref.read(reflectionRepositoryProvider);
      final reflection = await repo.get(widget.id!);
      
      if (reflection != null && mounted) {
        // Navigate to self-play runner
        final improved = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => SelfPlayRunner(
              reflectionId: widget.id!,
              reflection: reflection,
            ),
          ),
        );
        
        // Reload if improved
        if (improved == true) {
          await _load();
        }
      }
    }
  }
  
  Future<void> _applyTemplate() async {
    final template = await TemplatePickerDialog.show(context);
    if (template != null && mounted) {
      setState(() {
        if (template.whatPrompt.isNotEmpty) _what.text = template.whatPrompt;
        if (template.soWhatPrompt.isNotEmpty) _soWhat.text = template.soWhatPrompt;
        if (template.nowWhatPrompt.isNotEmpty) _nowWhat.text = template.nowWhatPrompt;
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
    final canRunSelfPlay = isEdit && 
      _title.text.isNotEmpty && 
      _what.text.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit? 'Edit Reflection' : 'New Reflection'),
        actions: [
          if (!isEdit)
            IconButton(
              onPressed: _applyTemplate,
              icon: const Icon(Icons.auto_stories),
              tooltip: 'Use template',
            ),
          HelpButton(
            title: 'Reflection Guide',
            content: 'Use the What/So What/Now What framework to structure your reflection:\n\n'
                '• What: Describe what happened objectively\n'
                '• So What: Analyze the significance and your learning\n'
                '• Now What: Identify actions for future practice\n\n'
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
              const PopupMenuItem(
                value: 'exit',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, size: 20),
                    SizedBox(width: 12),
                    Text('Exit without saving'),
                  ],
                ),
              ),
              if (isEdit)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete reflection', style: TextStyle(color: Colors.red)),
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
            controller: _what,
            decoration: const InputDecoration(
              labelText: 'What happened?',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            minLines: 4,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _soWhat,
            decoration: const InputDecoration(
              labelText: 'So what? (Analysis)',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            minLines: 4,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nowWhat,
            decoration: const InputDecoration(
              labelText: 'Now what? (Action)',
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            minLines: 4,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tags,
            decoration: const InputDecoration(
              labelText: 'Tags (comma separated)',
              border: OutlineInputBorder(),
            ),
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
                    color: Colors.black.withOpacity(0.3),
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
