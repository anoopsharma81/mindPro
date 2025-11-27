import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/learning_loop.dart';
import '../data/learning_loop_repository.dart';
import '../services/learning_loop_service.dart';
import '../../reflections/data/reflection.dart';
import '../../reflections/data/reflection_repository.dart';
import '../../auth/auth_provider.dart';
import '../../../core/logger.dart';
import 'widgets/gate_section.dart';
import 'widgets/observation_section.dart';
import 'widgets/encoding_section.dart';
import 'widgets/prediction_section.dart';
import 'widgets/feedback_section.dart';
import 'widgets/bias_section.dart';
import 'widgets/update_rule_section.dart';

const _uuid = Uuid();

class LearningLoopPage extends ConsumerStatefulWidget {
  final String reflectionId;
  final String? learningLoopId;
  
  const LearningLoopPage({
    super.key,
    required this.reflectionId,
    this.learningLoopId,
  });
  
  @override
  ConsumerState<LearningLoopPage> createState() => _LearningLoopPageState();
}

class _LearningLoopPageState extends ConsumerState<LearningLoopPage> {
  LearningLoop? _loop;
  Reflection? _reflection;
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _load();
  }
  
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Load reflection
      final reflectionRepo = ref.read(reflectionRepositoryProvider);
      _reflection = await reflectionRepo.get(widget.reflectionId);
      
      if (_reflection == null) {
        throw Exception('Reflection not found');
      }
      
      // Load existing loop
      final loopRepo = ref.read(learningLoopRepositoryProvider);
      if (widget.learningLoopId != null) {
        _loop = await loopRepo.get(widget.learningLoopId!);
      } else {
        // Check if loop exists for this reflection
        _loop = await loopRepo.getByReflectionId(widget.reflectionId);
      }
      
      setState(() => _isLoading = false);
      
      // If no loop exists, offer to generate
      if (_loop == null && mounted) {
        _showGenerateDialog();
      }
    } catch (e, stack) {
      Logger.error('Failed to load learning loop', e, stack);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    
    try {
      // Get current user
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Call API to generate
      final service = ref.read(learningLoopServiceProvider);
      final loopJson = await service.generateFromReflection(_reflection!);
      
      Logger.info('Received learning loop JSON: ${loopJson.keys}');
      
      // Convert API response to LearningLoop object
      final loopId = _uuid.v4();
      final now = DateTime.now();
      
      // Parse the sections from API response
      final gate = loopJson['gate'] as Map<String, dynamic>? ?? {};
      final obsAction = loopJson['observation_action'] as Map<String, dynamic>? ?? {};
      final encoding = loopJson['encoding'] as Map<String, dynamic>? ?? {};
      final prediction = loopJson['prediction'] as Map<String, dynamic>? ?? {};
      final feedback = loopJson['feedback'] as Map<String, dynamic>? ?? {};
      final bias = loopJson['reflection_bias'] as Map<String, dynamic>? ?? {};
      final updateRule = loopJson['update_rule'] as Map<String, dynamic>? ?? {};
      
      final loop = LearningLoop(
        id: loopId,
        reflectionId: widget.reflectionId,
        createdAt: now,
        updatedAt: now,
        userId: user.uid,
        
        // Gate
        attentionLevel: gate['attention_0_3'] as int? ?? 2,
        emotionValence: gate['emotion_valence_-3_+3'] as int? ?? 0,
        emotionArousal: gate['emotion_arousal_0_3'] as int? ?? 1,
        contextNote: gate['context_note'] as String?,
        
        // Observation & Action
        observations: (obsAction['observations'] as List?)?.cast<String>() ?? [],
        action: obsAction['action'] as String?,
        
        // Encoding
        patternName: encoding['pattern_name'] as String? ?? 'Clinical Pattern',
        priorKnowledgeLinks: (encoding['links_prior_knowledge'] as List?)?.cast<String>() ?? [],
        chunkTags: (encoding['chunk_tags'] as List?)?.cast<String>() ?? [],
        
        // Prediction
        hypothesis: prediction['hypothesis'] as String? ?? '',
        probabilityPercent: prediction['probability_pct'] as int? ?? 50,
        discriminators: (prediction['discriminators_expected'] as List?)?.cast<String>() ?? [],
        confidenceBucket: prediction['confidence_bucket'] as int? ?? 50,
        
        // Feedback
        outcome: feedback['outcome'] as String? ?? '',
        errorSignal: feedback['error_signal'] as String?,
        
        // Bias
        biases: (bias['bias_tags'] as List?)?.cast<String>() ?? [],
        counterMoves: (bias['counter_moves'] as List?)?.cast<String>() ?? [],
        
        // Update Rule
        ifThenRule: updateRule['if_then'] as String? ?? '',
        microRep48h: updateRule['micro_rep_48h'] as String?,
        spacedPlanDays: (updateRule['spaced_plan_days'] as List?)?.cast<int>() ?? [],
      );
      
      // Save to Firestore
      final loopRepo = ref.read(learningLoopRepositoryProvider);
      await loopRepo.save(loop);
      
      // Update reflection with learningLoopId
      final reflectionRepo = ref.read(reflectionRepositoryProvider);
      await reflectionRepo.update(
        _reflection!.id,
        _reflection!.copyWith(learningLoopId: loop.id)
      );
      
      setState(() {
        _loop = loop;
        _isGenerating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Learning Loop generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('Failed to generate learning loop', e, stack);
      setState(() {
        _error = e.toString();
        _isGenerating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.psychology, size: 48, color: Colors.purple),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Generate Learning Loop',
                style: TextStyle(color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(ctx);
                context.pop(); // Go back to reflection
              },
              tooltip: 'Exit',
            ),
          ],
        ),
        content: const Text(
          'Would you like to generate a Learning Loop for this reflection?\n\n'
          'This will use AI to structure your learning using cognitive science principles '
          'including pattern recognition, prediction tracking, bias identification, and spaced repetition.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop(); // Go back to reflection
            },
            child: const Text('Exit'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _generate();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _recordPredictionOutcome(bool wasCorrect) async {
    if (_loop == null) return;
    
    try {
      final loopRepo = ref.read(learningLoopRepositoryProvider);
      await loopRepo.recordPredictionOutcome(_loop!.id, wasCorrect);
      
      // Reload
      _loop = await loopRepo.get(_loop!.id);
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasCorrect 
              ? '✅ Prediction marked as Hit!' 
              : '❌ Prediction marked as Miss'),
            backgroundColor: wasCorrect ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('Failed to record prediction outcome', e, stack);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Loop'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Loop'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Learning Loop',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_isGenerating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Loop'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
                const SizedBox(height: 24),
                Text(
                  'Generating Learning Loop...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This may take 10-15 seconds',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Analyzing your reflection using cognitive science principles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_loop == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Loop'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 24),
                Text(
                  'No Learning Loop Yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Transform this reflection into a structured learning experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate with AI'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Display the learning loop
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Loop'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'About Learning Loop',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Link to parent reflection
            Card(
              color: Colors.grey.shade50,
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: Text(_reflection?.title ?? 'Reflection'),
                subtitle: const Text('Source reflection'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.go('/reflections/${widget.reflectionId}'),
              ),
            ),
            const SizedBox(height: 16),
            
            // GATE Section
            GateSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // OBSERVATION & ACTION Section
            ObservationSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // ENCODING Section
            EncodingSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // PREDICTION Section
            PredictionSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // FEEDBACK Section
            FeedbackSection(
              loop: _loop!,
              onPredictionOutcome: _recordPredictionOutcome,
            ),
            const SizedBox(height: 12),
            
            // BIAS Section
            BiasSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // UPDATE RULE Section
            UpdateRuleSection(loop: _loop!),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Colors.purple),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Learning Loop',
                style: TextStyle(color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
              tooltip: 'Close',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The Learning Loop is a cognitive science-based framework with 7 steps:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoItem('🔓 GATE', 'Emotional & attentional state'),
              _buildInfoItem('👁️ OBSERVATION', 'Key findings & actions'),
              _buildInfoItem('🧩 ENCODING', 'Pattern recognition'),
              _buildInfoItem('🎯 PREDICTION', 'Hypothesis & confidence'),
              _buildInfoItem('📊 FEEDBACK', 'Outcome comparison'),
              _buildInfoItem('🧠 BIAS', 'Cognitive trap identification'),
              _buildInfoItem('✅ UPDATE', 'Learning rule & spaced repetition'),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(String icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon, 
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

