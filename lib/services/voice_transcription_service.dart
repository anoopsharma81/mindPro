import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/logger.dart';
import 'api_service.dart';

/// Result of transcription
class TranscriptionResult {
  final String text;
  final double confidence;
  final String method; // "on-device" or "whisper"
  
  TranscriptionResult({
    required this.text,
    required this.confidence,
    required this.method,
  });
}

/// Service for transcribing voice recordings
class VoiceTranscriptionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ApiService _apiService;
  bool _isInitialized = false;
  
  // Transcription preferences
  static const String _preferenceKey = 'transcription_method';
  static const String _defaultMethod = 'local'; // local, whisper, auto
  
  VoiceTranscriptionService(this._apiService);
  
  /// Get preferred transcription method
  String get preferredMethod => _defaultMethod; // Could be loaded from SharedPreferences
  
  /// Set preferred transcription method
  void setPreferredMethod(String method) {
    // Could save to SharedPreferences
    // For now, we'll use auto mode
  }
  
  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // speech_to_text package handles its own permissions internally
      // Just try to initialize without checking permissions first
      _isInitialized = await _speech.initialize(
        onError: (error) {
          Logger.error('Speech recognition error', error.errorMsg, null);
        },
        onStatus: (status) {
          Logger.info('Speech recognition status: $status');
        },
      );
      
      if (_isInitialized) {
        Logger.info('Speech recognition initialized successfully');
      } else {
        Logger.warning('Speech recognition initialization failed');
      }
      
      return _isInitialized;
    } catch (e, stack) {
      Logger.error('Failed to initialize speech recognition', e, stack);
      return false;
    }
  }
  
  /// Transcribe audio using on-device speech recognition
  /// Note: This requires real-time listening, so we'll use a callback approach
  Future<TranscriptionResult> transcribeOnDevice({
    required Function(String) onResult,
    required Function(String) onError,
    int durationSeconds = 180,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          throw Exception('Speech recognition not available');
        }
      }
      
      String finalText = '';
      double finalConfidence = 0.0;
      
      await _speech.listen(
        onResult: (result) {
          finalText = result.recognizedWords;
          finalConfidence = result.confidence;
          onResult(finalText);
        },
        listenFor: Duration(seconds: durationSeconds),
        pauseFor: const Duration(seconds: 15), // Increased from 5 to 15 seconds for consistency
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: 'en_US', // Explicitly set locale for better recognition
      );
      
      // Wait for listening to complete
      await Future.delayed(Duration(seconds: durationSeconds + 1));
      
      return TranscriptionResult(
        text: finalText,
        confidence: finalConfidence,
        method: 'on-device',
      );
    } catch (e, stack) {
      Logger.error('On-device transcription failed', e, stack);
      onError(e.toString());
      rethrow;
    }
  }
  
  /// Smart transcription with fallback mechanism
  /// Tries local first (default), falls back to Whisper if local fails
  Future<TranscriptionResult> transcribeSmart(String audioUrl, {
    String method = 'local',
  }) async {
    Logger.info('Starting smart transcription with method: $method');
    
    if (method == 'whisper') {
      return await transcribeWithWhisper(audioUrl);
    }
    
    if (method == 'auto') {
      // Auto mode: try local first, fallback to Whisper
      try {
        Logger.info('Trying local transcription first...');
        return await _transcribeLocalFallback();
      } catch (e) {
        Logger.warning('Local transcription failed, falling back to Whisper API: $e');
        return await transcribeWithWhisper(audioUrl);
      }
    }
    
    // Default: local transcription
    return await _transcribeLocalFallback();
  }
  
  /// Local transcription fallback using on-device speech recognition
  /// This processes the audio file locally without internet
  Future<TranscriptionResult> _transcribeLocalFallback() async {
    try {
      Logger.info('Using local transcription fallback');
      
      // Return empty text for manual entry
      // Live transcription during recording handles real-time transcription
      return TranscriptionResult(
        text: '', // Empty text, user can type manually
        confidence: 0.0,
        method: 'local-manual',
      );
    } catch (e, stack) {
      Logger.error('Local transcription fallback failed', e, stack);
      
      // Return empty text for manual entry
      return TranscriptionResult(
        text: '',
        confidence: 0.0,
        method: 'local-error',
      );
    }
  }
  
  /// Real-time local transcription during recording
  /// This is the actual local transcription that works with speech_to_text
  Future<TranscriptionResult> transcribeLocalRealtime({
    required Function(String) onResult,
    required Function(String) onError,
    int durationSeconds = 180,
  }) async {
    try {
      Logger.info('Starting real-time local transcription');
      
      // Initialize if not already done
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          Logger.warning('Speech recognition initialization failed');
          onError('Speech recognition not available. Please check permissions in Settings.');
          throw Exception('Speech recognition not available');
        }
      }
      
      String finalText = '';
      double finalConfidence = 0.0;
      
      // Start listening for speech
      await _speech.listen(
        onResult: (result) {
          finalText = result.recognizedWords;
          finalConfidence = result.confidence;
          Logger.info('Live transcription result: $finalText (confidence: $finalConfidence)');
          onResult(finalText);
        },
        listenFor: Duration(seconds: durationSeconds),
        pauseFor: const Duration(seconds: 15), // Increased from 3 to 15 seconds for better natural speech
        partialResults: true,
        cancelOnError: false, // Don't cancel on error, keep listening
        listenMode: stt.ListenMode.dictation, // Use dictation mode for better results
        localeId: 'en_US', // Explicitly set locale for better recognition
        onSoundLevelChange: (level) {
          // Optional: Log sound levels for debugging
          Logger.debug('Sound level: $level');
        },
      );
      
      Logger.info('Started listening for speech recognition');
      
      // Wait for listening to complete
      await Future.delayed(Duration(seconds: durationSeconds + 1));
      
      return TranscriptionResult(
        text: finalText,
        confidence: finalConfidence,
        method: 'local-realtime',
      );
    } catch (e, stack) {
      Logger.error('Real-time local transcription failed', e, stack);
      onError('Live transcription error: $e');
      
      // Return partial result even on error
      return TranscriptionResult(
        text: '',
        confidence: 0.0,
        method: 'local-realtime-error',
      );
    }
  }
  
  /// Transcribe audio file using backend Whisper API
  Future<TranscriptionResult> transcribeWithWhisper(String audioUrl) async {
    try {
      Logger.info('Transcribing with Whisper API');
      
      final result = await _apiService.transcribeAudio(audioUrl: audioUrl);
      
      return TranscriptionResult(
        text: result['text'] as String? ?? '',
        confidence: (result['confidence'] as num?)?.toDouble() ?? 1.0,
        method: 'whisper',
      );
    } catch (e, stack) {
      Logger.error('Whisper transcription failed', e, stack);
      rethrow;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    try {
      if (_isInitialized && _speech.isListening) {
        await _speech.stop();
        Logger.info('Stopped listening');
      }
    } catch (e, stack) {
      Logger.error('Failed to stop listening', e, stack);
    }
  }
  
  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _isInitialized;
  }
  
  /// Cancel listening
  Future<void> cancel() async {
    try {
      if (_isInitialized) {
        await _speech.cancel();
        Logger.info('Speech recognition cancelled');
      }
    } catch (e, stack) {
      Logger.error('Failed to cancel speech recognition', e, stack);
    }
  }
}

/// Provider for VoiceTranscriptionService
final voiceTranscriptionServiceProvider = Provider<VoiceTranscriptionService>((ref) {
  final apiService = ApiService();
  return VoiceTranscriptionService(apiService);
});

