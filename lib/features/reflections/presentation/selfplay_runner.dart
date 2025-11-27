import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../common/widgets/rating_widget.dart';
import '../../../core/logger.dart';
import '../data/reflection.dart';
import '../data/reflection_repository.dart';

/// Self-play runner for AI-powered reflection improvement
class SelfPlayRunner extends ConsumerStatefulWidget {
  final String reflectionId;
  final Reflection reflection;
  
  const SelfPlayRunner({
    super.key,
    required this.reflectionId,
    required this.reflection,
  });
  
  @override
  ConsumerState<SelfPlayRunner> createState() => _SelfPlayRunnerState();
}

class _SelfPlayRunnerState extends ConsumerState<SelfPlayRunner> {
  final ApiService _apiService = ApiService();
  bool _isRunning = false;
  bool _isComplete = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  int _iterations = 1; // Reduced from 3 for faster results
  int? _userRating;
  
  Future<void> _runSelfPlay() async {
    setState(() {
      _isRunning = true;
      _errorMessage = null;
      _result = null;
    });
    
    try {
      final year = ref.read(selectedYearProvider);
      
      // Build context from reflection
      final context = '''
Title: ${widget.reflection.title}

What happened: ${widget.reflection.what}

So what (analysis): ${widget.reflection.soWhat}

Now what (action): ${widget.reflection.nowWhat}
''';
      
      // Call self-play API
      final response = await _apiService.runSelfPlay(
        year: year,
        title: widget.reflection.title,
        context: context,
        iterations: _iterations,
      );
      
      setState(() {
        _result = response;
        _isComplete = true;
      });
      
      Logger.info('Self-play complete for reflection: ${widget.reflectionId}');
    } catch (e, stack) {
      Logger.error('Self-play failed', e, stack);
      setState(() {
        _errorMessage = 'AI improvement failed. Please try again or continue without AI assistance.\n\nError: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }
  
  Future<void> _acceptAndSave() async {
    if (_result == null) return;
    
    try {
      final repo = ref.read(reflectionRepositoryProvider);
      
      // Get improved text from backend response
      final improvedText = _result!['improved'] as String? ?? '';
      
      // Parse improved text into What/So What/Now What sections
      // For now, just put all improved text in "what" field
      // TODO: Parse structured output
      
      // Update reflection with AI-improved text
      final updated = widget.reflection.copyWith(
        what: improvedText, // Put improved text in "what" field
        score: (_result!['score'] as num?)?.toDouble(),
        iterations: _result!['history'] as List<Map<String, dynamic>>?,
        rating: _userRating,
      );
      
      await repo.update(widget.reflectionId, updated);
      
      // Submit rating if provided
      if (_userRating != null) {
        final year = ref.read(selectedYearProvider);
        await _apiService.reinforceReflection(
          year: year,
          rid: widget.reflectionId,
          rating: _userRating!,
        );
        Logger.info('Rating submitted: $_userRating');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI improvements saved successfully!')),
        );
        Navigator.of(context).pop(true); // Return to reflection editor
      }
    } catch (e, stack) {
      Logger.error('Failed to save AI improvements', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Reflection Improvement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Metanoia AI Assistant',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The AI will review your reflection and suggest improvements through iterative refinement. This helps enhance clarity, depth, and learning outcomes.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Iterations selector
            if (!_isComplete) ...[
              const Text(
                'Number of iterations',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF5F3F0),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _iterations.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_iterations iterations',
                      onChanged: _isRunning ? null : (value) {
                        setState(() {
                          _iterations = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text(
                    '$_iterations',
                    style: const TextStyle(color: Color(0xFFF5F3F0)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            
            // Run button
            if (!_isComplete)
              FilledButton.icon(
                onPressed: _isRunning ? null : _runSelfPlay,
                icon: _isRunning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology),
                label: Text(_isRunning ? 'Running AI...' : 'Improve with AI'),
              ),
            
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Dismiss',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Results
            if (_isComplete && _result != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Improvement Complete',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_result!['score'] != null) ...[
                        Text(
                          'Quality Score: ${((_result!['score'] as num) * 10).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Before/After Comparison
              if (_result!['improved'] != null) ...[
                // Original Text
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.article_outlined, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            const Text(
                              'BEFORE (Original)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '''${widget.reflection.what}

${widget.reflection.soWhat.isNotEmpty ? 'Analysis: ${widget.reflection.soWhat}\n' : ''}${widget.reflection.nowWhat.isNotEmpty ? 'Action: ${widget.reflection.nowWhat}' : ''}'''.trim(),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Improved Text
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'AFTER (AI Improved)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Text(
                            _result!['improved'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              
              // Rating widget
              RatingWidget(
                currentRating: _userRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _userRating = rating;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Return without saving
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Reject Changes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _acceptAndSave,
                      icon: const Icon(Icons.check),
                      label: const Text('Accept & Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


