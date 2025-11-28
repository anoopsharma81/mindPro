import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/metanoia_reflection_repository.dart';
import '../../../metanoia_reflection_schema.dart';
import '../../../common/widgets/help_tooltip.dart';
import '../../../services/api_service.dart';
import '../../../core/logger.dart';

const _uuid = Uuid();

class MetanoiaReflectionEditPage extends ConsumerStatefulWidget {
  final String? id;
  const MetanoiaReflectionEditPage({super.key, this.id});

  @override
  ConsumerState<MetanoiaReflectionEditPage> createState() => _MetanoiaReflectionEditPageState();
}

class _MetanoiaReflectionEditPageState extends ConsumerState<MetanoiaReflectionEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _caseTitleController = TextEditingController();
  final _caseDescriptionController = TextEditingController();
  
  // Pattern Recognition
  final _keyFeaturesController = TextEditingController();
  final _prototypeController = TextEditingController();
  
  // Analytical Reasoning
  final _initialDifferentialController = TextEditingController();
  final _discriminatorsController = TextEditingController();
  final _managementLogicController = TextEditingController();
  
  // Bias Filtering
  final _identifiedBiasesController = TextEditingController();
  final _correctiveRulesController = TextEditingController();
  
  // Learning Block
  final _encodingController = TextEditingController();
  final _predictionController = TextEditingController();
  final _updateController = TextEditingController();
  
  // Retrieval Plan
  final _sixWeeksController = TextEditingController();
  final _sixMonthsController = TextEditingController();
  final _twelveMonthsController = TextEditingController();
  
  // Metadata
  final _authorController = TextEditingController();
  final _domainController = TextEditingController();
  
  MetanoiaReflection? _model;
  bool _hasLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.id != null) {
      setState(() => _isLoading = true);
      try {
        final repo = ref.read(metanoiaReflectionRepositoryProvider);
        final m = await repo.get(widget.id!);
        if (m != null) {
          _model = m;
          _populateFields(m);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load reflection: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasLoaded = true;
          });
        }
      }
    } else {
      _hasLoaded = true;
    }
  }

  void _populateFields(MetanoiaReflection reflection) {
    _caseTitleController.text = reflection.caseTitle;
    _caseDescriptionController.text = reflection.caseDescription;
    
    _keyFeaturesController.text = reflection.patternRecognition.keyFeatures.join('\n');
    _prototypeController.text = reflection.patternRecognition.prototype;
    
    _initialDifferentialController.text = reflection.analyticalReasoning.initialDifferential.join('\n');
    _discriminatorsController.text = reflection.analyticalReasoning.discriminatorsForDiagnosis.join('\n');
    _managementLogicController.text = reflection.analyticalReasoning.managementLogic.join('\n');
    
    _identifiedBiasesController.text = reflection.biasFiltering.identifiedBiases.join('\n');
    _correctiveRulesController.text = reflection.biasFiltering.correctiveRules.join('\n');
    
    _encodingController.text = reflection.learning.encoding;
    _predictionController.text = reflection.learning.prediction;
    _updateController.text = reflection.learning.update;
    
    _sixWeeksController.text = reflection.retrievalPlan.sixWeeks;
    _sixMonthsController.text = reflection.retrievalPlan.sixMonths;
    _twelveMonthsController.text = reflection.retrievalPlan.twelveMonths;
    
    _authorController.text = reflection.author ?? '';
    _domainController.text = reflection.domain ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(metanoiaReflectionRepositoryProvider);
      final now = DateTime.now();
      
      final reflection = MetanoiaReflection(
        id: _model?.id ?? _uuid.v4(),
        caseTitle: _caseTitleController.text.trim(),
        caseDescription: _caseDescriptionController.text.trim(),
        patternRecognition: PatternRecognition(
          keyFeatures: _keyFeaturesController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList(),
          prototype: _prototypeController.text.trim(),
        ),
        analyticalReasoning: AnalyticalReasoning(
          initialDifferential: _initialDifferentialController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList(),
          discriminatorsForDiagnosis: _discriminatorsController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList(),
          managementLogic: _managementLogicController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList(),
        ),
        biasFiltering: BiasFiltering(
          identifiedBiases: _identifiedBiasesController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList(),
          correctiveRules: _correctiveRulesController.text
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList(),
        ),
        learning: LearningBlock(
          encoding: _encodingController.text.trim(),
          prediction: _predictionController.text.trim(),
          update: _updateController.text.trim(),
        ),
        retrievalPlan: RetrievalPlan(
          sixWeeks: _sixWeeksController.text.trim(),
          sixMonths: _sixMonthsController.text.trim(),
          twelveMonths: _twelveMonthsController.text.trim(),
        ),
        createdAt: _model?.createdAt ?? now,
        updatedAt: now,
        author: _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
        domain: _domainController.text.trim().isEmpty ? null : _domainController.text.trim(),
      );
      
      if (_model == null) {
        await repo.create(reflection);
      } else {
        await repo.update(reflection.id, reflection);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reflection saved successfully')),
        );
        context.go('/metanoia');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPresExample() async {
    final pres = presReflectionJson();
    final reflection = MetanoiaReflection.fromJson(pres);
    _populateFields(reflection);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loaded PRES example template')),
      );
    }
  }

  Future<void> _generateFromInput() async {
    // Show dialog to get user input
    final caseNotes = await showDialog<String>(
      context: context,
      builder: (context) => _CaseNotesInputDialog(),
    );

    if (caseNotes == null || caseNotes.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      Logger.info('Generating Metanoia reflection from case notes (${caseNotes.length} chars)');

      final result = await apiService.generateMetanoiaReflection(
        caseNotes: caseNotes,
        domain: _domainController.text.trim().isEmpty ? null : _domainController.text.trim(),
      );

      // Parse the result into MetanoiaReflection
      final reflection = MetanoiaReflection.fromJson(result);
      _populateFields(reflection);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Metanoia reflection generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('Failed to generate Metanoia reflection', e, stack);
      if (mounted) {
        // Extract error message
        String errorMessage = 'Failed to generate Metanoia reflection.';
        
        if (e is Exception) {
          final errorStr = e.toString();
          // Remove "Exception: " prefix if present
          errorMessage = errorStr.replaceFirst(RegExp(r'^Exception:\s*'), '');
        } else {
          errorMessage = e.toString();
        }
        
        // Clean up any extra formatting
        errorMessage = errorMessage.trim();
        if (errorMessage.isEmpty) {
          errorMessage = 'An unknown error occurred. Please try again.';
        }
        
        // Show error in a dialog for better visibility of long messages
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF0C2F37),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Generation Failed',
                  style: TextStyle(color: Color(0xFFF5F3F0)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Color(0xFFF5F3F0)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFFF5F3F0)),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _caseTitleController.dispose();
    _caseDescriptionController.dispose();
    _keyFeaturesController.dispose();
    _prototypeController.dispose();
    _initialDifferentialController.dispose();
    _discriminatorsController.dispose();
    _managementLogicController.dispose();
    _identifiedBiasesController.dispose();
    _correctiveRulesController.dispose();
    _encodingController.dispose();
    _predictionController.dispose();
    _updateController.dispose();
    _sixWeeksController.dispose();
    _sixMonthsController.dispose();
    _twelveMonthsController.dispose();
    _authorController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoaded || _isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0C2F37),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C2F37),
          title: const Text('Metanoia Reflection'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C2F37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2F37),
        title: Text(widget.id != null ? 'Edit Metanoia Reflection' : 'New Metanoia Reflection'),
        actions: [
          HelpButton(
            title: 'Metanoia Reflection Guide',
            content: 'The Metanoia framework structures clinical reflections into:\n\n'
                '• Pattern Recognition: Key features and mental shortcuts\n'
                '• Analytical Reasoning: Differential diagnosis and management logic\n'
                '• Bias Filtering: Cognitive biases and corrective strategies\n'
                '• Learning: Encoding, prediction, and mental model updates\n'
                '• Retrieval Plan: Spaced repetition schedule (6 weeks, 6 months, 12 months)',
            tips: [
              'Use the PRES example as a template',
              'Focus on clinical decision-making patterns',
              'Be specific about biases and corrective rules',
            ],
          ),
          if (widget.id == null) ...[
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Generate from case notes',
              onPressed: _isLoading ? null : _generateFromInput,
            ),
            IconButton(
              icon: const Icon(Icons.auto_stories),
              tooltip: 'Load PRES example',
              onPressed: _isLoading ? null : _loadPresExample,
            ),
          ],
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                'Case Information',
                Icons.description,
                [
                  _buildTextField(
                    _caseTitleController,
                    'Case Title',
                    'e.g., "Headache that turned out to be PRES"',
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _caseDescriptionController,
                    'Case Description',
                    'Free text description of the case',
                    maxLines: 5,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _authorController,
                          'Author (optional)',
                          'e.g., "Dr Govind Chavada"',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          _domainController,
                          'Domain (optional)',
                          'e.g., "Neurology"',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Pattern Recognition',
                Icons.pattern,
                [
                  _buildTextField(
                    _keyFeaturesController,
                    'Key Features (one per line)',
                    'List the key clinical features',
                    maxLines: 4,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _prototypeController,
                    'Prototype Pattern',
                    'The "if pattern then..." mental shortcut',
                    maxLines: 2,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Analytical Reasoning',
                Icons.psychology,
                [
                  _buildTextField(
                    _initialDifferentialController,
                    'Initial Differential (one per line)',
                    'List possible diagnoses',
                    maxLines: 4,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _discriminatorsController,
                    'Discriminators for Diagnosis (one per line)',
                    'Key features that distinguish the diagnosis',
                    maxLines: 4,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _managementLogicController,
                    'Management Logic (one per line)',
                    'Steps in management approach',
                    maxLines: 4,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Bias Filtering',
                Icons.filter_alt,
                [
                  _buildTextField(
                    _identifiedBiasesController,
                    'Identified Biases (one per line)',
                    'Cognitive biases that affected reasoning',
                    maxLines: 4,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _correctiveRulesController,
                    'Corrective Rules (one per line)',
                    'Strategies to counter identified biases',
                    maxLines: 4,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Learning Block',
                Icons.school,
                [
                  _buildTextField(
                    _encodingController,
                    'Encoding',
                    'What I want to store',
                    maxLines: 3,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _predictionController,
                    'Prediction',
                    'How I want to behave next time',
                    maxLines: 3,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _updateController,
                    'Update',
                    'How my mental model changes',
                    maxLines: 3,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Retrieval Plan',
                Icons.schedule,
                [
                  _buildTextField(
                    _sixWeeksController,
                    '6 Weeks Review',
                    'What to recall at 6 weeks',
                    maxLines: 2,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _sixMonthsController,
                    '6 Months Review',
                    'What to review at 6 months',
                    maxLines: 2,
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _twelveMonthsController,
                    '12 Months Review',
                    'What to review at 12 months',
                    maxLines: 2,
                    required: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Reflection'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      color: Colors.black.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFF5F3F0)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF5F3F0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Color(0xFFF5F3F0)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFF5F3F0)),
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFF5F3F0).withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFFF5F3F0).withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFFF5F3F0).withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFF5F3F0)),
        ),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
      ),
      maxLines: maxLines,
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }
}

/// Dialog for inputting case notes to generate Metanoia reflection
class _CaseNotesInputDialog extends StatefulWidget {
  @override
  State<_CaseNotesInputDialog> createState() => _CaseNotesInputDialogState();
}

class _CaseNotesInputDialogState extends State<_CaseNotesInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0C2F37),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFF5F3F0)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Generate Metanoia Reflection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F3F0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFFF5F3F0)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter your case notes or clinical scenario. AI will generate a structured Metanoia reflection with pattern recognition, analytical reasoning, bias filtering, learning, and retrieval plan.',
                style: TextStyle(
                  color: Color(0xFFF5F3F0),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  style: const TextStyle(color: Color(0xFFF5F3F0)),
                  decoration: InputDecoration(
                    labelText: 'Case Notes',
                    labelStyle: const TextStyle(color: Color(0xFFF5F3F0)),
                    hintText: 'Describe the clinical case, situation, or scenario...',
                    hintStyle: TextStyle(color: const Color(0xFFF5F3F0).withValues(alpha: 0.6)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFF5F3F0).withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFF5F3F0).withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF5F3F0)),
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter case notes';
                    }
                    if (value.trim().length < 50) {
                      return 'Please provide more detail (at least 50 characters)';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFFF5F3F0))),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, _controller.text.trim());
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('Generate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

