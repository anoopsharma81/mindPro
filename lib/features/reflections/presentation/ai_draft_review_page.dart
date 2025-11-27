import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/document_extraction_service.dart';
import '../../../common/widgets/gmc_domain_selector.dart';
import '../../../common/utils/phi_detector.dart';
import '../../../common/widgets/phi_warning_dialog.dart';
import '../data/reflection.dart';
import '../data/reflection_repository.dart';
import 'package:uuid/uuid.dart';

/// Page for reviewing and editing AI-generated reflection draft
class AiDraftReviewPage extends ConsumerStatefulWidget {
  final ExtractionResult extractionResult;
  final String sourceType;
  final String? sourceUrl;

  const AiDraftReviewPage({
    super.key,
    required this.extractionResult,
    required this.sourceType,
    this.sourceUrl,
  });

  @override
  ConsumerState<AiDraftReviewPage> createState() => _AiDraftReviewPageState();
}

class _AiDraftReviewPageState extends ConsumerState<AiDraftReviewPage> {
  late TextEditingController _titleController;
  late TextEditingController _whatController;
  late TextEditingController _soWhatController;
  late TextEditingController _nowWhatController;
  late TextEditingController _tagsController;
  late List<int> _selectedDomains;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final result = widget.extractionResult;
    _titleController = TextEditingController(text: result.title);
    _whatController = TextEditingController(text: result.what);
    _soWhatController = TextEditingController(text: result.soWhat);
    _nowWhatController = TextEditingController(text: result.nowWhat);
    _tagsController = TextEditingController(text: result.tags.join(', '));
    _selectedDomains = List.from(result.suggestedDomains);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _whatController.dispose();
    _soWhatController.dispose();
    _nowWhatController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Check for PHI
    final fullText = '${_titleController.text} ${_whatController.text} ${_soWhatController.text} ${_nowWhatController.text}';
    if (PhiDetector.containsPhi(fullText)) {
      final shouldContinue = await PhiWarningDialog.show(context, fullText);
      if (!shouldContinue) return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(reflectionRepositoryProvider);
      final now = DateTime.now();
      
      final reflection = Reflection(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        what: _whatController.text.trim(),
        soWhat: _soWhatController.text.trim(),
        nowWhat: _nowWhatController.text.trim(),
        tags: _tagsController.text
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
        createdAt: now,
        updatedAt: now,
        linkedCpdIds: [],
        domains: _selectedDomains.isEmpty ? null : _selectedDomains,
        // AI Extraction metadata
        sourceType: widget.sourceType,
        extractedText: widget.extractionResult.extractedText,
        sourceUrl: widget.sourceUrl,
        aiConfidence: widget.extractionResult.confidence,
        isAiGenerated: true,
        extractedAt: now,
      );

      await repo.save(reflection);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ AI-generated reflection saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to reflections list
        context.go('/reflections');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _discard() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft discarded')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confidence = widget.extractionResult.confidence;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review AI Draft'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'About AI Extraction',
                    style: TextStyle(color: Colors.black),
                  ),
                  content: const Text(
                    'AI has analyzed your content and created a structured reflection. '
                    'Please review and edit as needed before saving. '
                    'Always check for patient-identifiable information (PHI).',
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI-Generated Draft',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(0)}% • Review and edit as needed',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Help tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Review and edit the AI-generated content. The AI made a first draft for you!',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // What
            TextField(
              controller: _whatController,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                border: OutlineInputBorder(),
                helperText: 'Objective description of the event',
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 16),

            // So What
            TextField(
              controller: _soWhatController,
              decoration: const InputDecoration(
                labelText: 'So what? (Analysis)',
                border: OutlineInputBorder(),
                helperText: 'What did you learn? What are the implications?',
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 16),

            // Now What
            TextField(
              controller: _nowWhatController,
              decoration: const InputDecoration(
                labelText: 'Now what? (Action)',
                border: OutlineInputBorder(),
                helperText: 'What will you do differently?',
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 16),

            // Tags
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // GMC Domains
            Text(
              'GMC Domains',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            GmcDomainSelector(
              selectedDomains: _selectedDomains,
              onChanged: (domains) {
                setState(() => _selectedDomains = domains);
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Reflection'),
            ),
            const SizedBox(height: 12),

            // Discard Button
            OutlinedButton(
              onPressed: _isSaving ? null : _discard,
              child: const Text('Discard'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

