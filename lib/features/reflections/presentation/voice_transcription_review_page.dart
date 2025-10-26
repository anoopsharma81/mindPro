import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/voice_transcription_service.dart';
import '../../../services/voice_recording_service.dart';
import '../../../services/api_service.dart';
import '../../../core/logger.dart';
import '../data/reflection_repository.dart';
import 'widgets/audio_player_widget.dart';

/// Page for reviewing transcribed voice note
class VoiceTranscriptionReviewPage extends ConsumerStatefulWidget {
  final String audioFilePath;
  final int durationSeconds;
  final String? preTranscription; // Pre-transcribed text from live transcription
  
  const VoiceTranscriptionReviewPage({
    super.key,
    required this.audioFilePath,
    required this.durationSeconds,
    this.preTranscription,
  });
  
  @override
  ConsumerState<VoiceTranscriptionReviewPage> createState() =>
      _VoiceTranscriptionReviewPageState();
}

class _VoiceTranscriptionReviewPageState
    extends ConsumerState<VoiceTranscriptionReviewPage> {
  late TextEditingController _transcriptionController;
  bool _isTranscribing = false;
  bool _isSaving = false;
  bool _isGeneratingAI = false;
  bool _keepAudio = true;
  double _confidence = 0.0;
  String _transcriptionMethod = 'whisper'; // Changed default to whisper for better quality
  String? _uploadedAudioUrl; // Cache uploaded URL to avoid double upload
  
  @override
  void initState() {
    super.initState();
    _transcriptionController = TextEditingController();
    
    // Set pre-transcription if available (from live transcription)
    if (widget.preTranscription != null && widget.preTranscription!.isNotEmpty) {
      _transcriptionController.text = widget.preTranscription!;
      _transcriptionMethod = 'local-realtime';
      _confidence = 0.8;
    }
    
    // Automatically start Whisper transcription (unless already have live transcription)
    if (widget.preTranscription == null || widget.preTranscription!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryWhisperAPI();
      });
    }
  }
  
  @override
  void dispose() {
    _transcriptionController.dispose();
    super.dispose();
  }
  
  
  Future<void> _tryWhisperAPI() async {
    setState(() => _isTranscribing = true);
    
    try {
      final recordingService = ref.read(voiceRecordingServiceProvider);
      final transcriptionService = ref.read(voiceTranscriptionServiceProvider);
      
      // Upload audio to Firebase Storage first (or use cached URL)
      final audioUrl = _uploadedAudioUrl ?? await recordingService.uploadAudio(widget.audioFilePath);
      _uploadedAudioUrl = audioUrl; // Cache for reuse
      
      // Transcribe with selected method
      final result = await transcriptionService.transcribeSmart(audioUrl, method: _transcriptionMethod);
      
      setState(() {
        _transcriptionController.text = result.text;
        _confidence = result.confidence;
        _transcriptionMethod = result.method;
        _isTranscribing = false;
      });
      
      if (mounted) {
        String message;
        Color backgroundColor;
        
        if (result.method.contains('whisper')) {
          message = '✨ Whisper API transcription completed! High-quality results ready.';
          backgroundColor = Colors.green;
        } else if (result.method.contains('local')) {
          message = '✨ Local transcription completed! For better quality, try Whisper API.';
          backgroundColor = Colors.orange;
        } else {
          message = '✨ Transcription completed using ${result.method}';
          backgroundColor = Colors.green;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('Whisper transcription failed', e, stack);
      setState(() => _isTranscribing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Whisper transcription failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _saveAsTranscription() async {
    if (_transcriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription is empty')),
      );
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      final recordingService = ref.read(voiceRecordingServiceProvider);
      final repo = ref.read(reflectionRepositoryProvider);
      
      // Upload audio if user wants to keep it (or use cached URL)
      if (_keepAudio && _uploadedAudioUrl == null) {
        _uploadedAudioUrl = await recordingService.uploadAudio(widget.audioFilePath);
      }
      
      // Create reflection with transcription as the main content
      final transcription = _transcriptionController.text.trim();
      final now = DateTime.now();
      
      // Create reflection with named parameters
      await repo.create(
        title: 'Voice Note - ${now.day}/${now.month}/${now.year}',
        what: transcription,
        soWhat: '',
        nowWhat: '',
        tags: [],
      );
      
      // Clean up temporary file
      await recordingService.deleteTemporaryFile(widget.audioFilePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Voice note saved as reflection'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/reflections');
      }
    } catch (e, stack) {
      Logger.error('Failed to save transcription', e, stack);
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _generateStructuredReflection() async {
    if (_transcriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcription is empty')),
      );
      return;
    }
    
    setState(() => _isGeneratingAI = true);
    
    try {
      final apiService = ApiService();
      final repo = ref.read(reflectionRepositoryProvider);
      
      // Call AI to structure the transcription
      final structured = await apiService.structureTranscription(
        transcription: _transcriptionController.text.trim(),
      );
      
      // Create reflection with AI-structured content
      Logger.info('Creating reflection with structured content...');
      await repo.create(
        title: structured['title'] as String? ?? 'Voice Reflection',
        what: structured['what'] as String? ?? _transcriptionController.text,
        soWhat: structured['soWhat'] as String? ?? '',
        nowWhat: structured['nowWhat'] as String? ?? '',
        tags: (structured['tags'] as List?)?.cast<String>() ?? [],
        domains: (structured['suggestedDomains'] as List?)?.cast<int>(),
      );
      Logger.info('Reflection created successfully');
      
      // Clean up temporary file
      Logger.info('Cleaning up temporary file...');
      final recordingService = ref.read(voiceRecordingServiceProvider);
      await recordingService.deleteTemporaryFile(widget.audioFilePath);
      Logger.info('Temporary file cleanup completed');
      
      if (mounted) {
        setState(() => _isGeneratingAI = false);
        Logger.info('Showing success message and navigating...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ AI-structured reflection created!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Logger.info('Navigating to reflections list...');
        context.go('/reflections');
        Logger.info('Navigation completed');
      }
    } catch (e, stack) {
      Logger.error('Failed to generate structured reflection', e, stack);
      setState(() => _isGeneratingAI = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Transcription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clean up audio file
            ref.read(voiceRecordingServiceProvider).deleteTemporaryFile(widget.audioFilePath);
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Audio player
            AudioPlayerWidget(
              audioPath: widget.audioFilePath,
              duration: widget.durationSeconds,
            ),
            const SizedBox(height: 24),
            
            // Transcription method selector
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transcription Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Local', style: TextStyle(fontSize: 12)),
                          subtitle: const Text('On-device, basic quality', style: TextStyle(fontSize: 10)),
                          value: 'local',
                          groupValue: _transcriptionMethod,
                          onChanged: (value) {
                            setState(() {
                              _transcriptionMethod = value!;
                            });
                          },
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Whisper API ⭐', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Best quality, requires internet', style: TextStyle(fontSize: 10, color: Colors.green)),
                          value: 'whisper',
                          groupValue: _transcriptionMethod,
                          onChanged: (value) {
                            setState(() {
                              _transcriptionMethod = value!;
                            });
                          },
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Auto (Smart)', style: TextStyle(fontSize: 12)),
                          subtitle: const Text('Local first, Whisper fallback', style: TextStyle(fontSize: 10)),
                          value: 'auto',
                          groupValue: _transcriptionMethod,
                          onChanged: (value) {
                            setState(() {
                              _transcriptionMethod = value!;
                            });
                          },
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Confidence indicator
            if (_confidence > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Confidence: ${(_confidence * 100).toStringAsFixed(0)}% ($_transcriptionMethod)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Transcription text
            if (_isTranscribing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Transcribing audio...'),
                  ],
                ),
              )
            else
              TextField(
                controller: _transcriptionController,
                decoration: const InputDecoration(
                  labelText: 'Transcription',
                  helperText: 'Edit the transcription as needed',
                  border: OutlineInputBorder(),
                ),
                maxLines: 12,
                minLines: 8,
              ),
            const SizedBox(height: 16),
            
            // Try Whisper API button (if not already using Whisper)
            if (!_transcriptionMethod.contains('whisper'))
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isTranscribing ? null : () async {
                    setState(() {
                      _transcriptionMethod = 'whisper';
                      _isTranscribing = true;
                    });
                    await _tryWhisperAPI();
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Try Whisper API for Better Quality'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Keep audio checkbox
            CheckboxListTile(
              value: _keepAudio,
              onChanged: (value) {
                setState(() => _keepAudio = value ?? true);
              },
              title: const Text('Keep Audio Recording'),
              subtitle: const Text('Attach audio file to reflection'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveAsTranscription,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save as Transcription'),
            ),
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: _isGeneratingAI ? null : _generateStructuredReflection,
              icon: _isGeneratingAI
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: const Text('Generate Structured Reflection'),
            ),
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: _isTranscribing ? null : _tryWhisperAPI,
              icon: const Icon(Icons.upgrade),
              label: const Text('Try Better Transcription (Whisper API)'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

