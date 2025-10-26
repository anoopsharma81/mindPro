import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/voice_recording_service.dart';
import '../../../services/voice_transcription_service.dart';
import '../../../core/logger.dart';
import 'widgets/voice_note_recorder.dart';
import 'voice_transcription_review_page.dart';

/// Voice note flow coordinator
/// Handles: Permission → Record → Transcribe → Review
class VoiceNoteFlowPage extends ConsumerStatefulWidget {
  const VoiceNoteFlowPage({super.key});
  
  @override
  ConsumerState<VoiceNoteFlowPage> createState() => _VoiceNoteFlowPageState();
}

class _VoiceNoteFlowPageState extends ConsumerState<VoiceNoteFlowPage> {
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;
  int _recordingDurationSeconds = 0;
  bool _permissionGranted = false;
  String _liveTranscription = ''; // Live transcription text
  bool _enableLiveTranscription = true; // Enable live transcription by default
  
  @override
  void initState() {
    super.initState();
    // Check permission first, only request if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionFirst();
    });
  }
  
  Future<void> _checkPermissionFirst() async {
    try {
      Logger.info('Checking microphone permission first...');
      
      // Use the voice recording service to check permission
      final service = ref.read(voiceRecordingServiceProvider);
      final hasPermission = await service.checkPermission();
      
      Logger.info('Initial permission check result: $hasPermission');
      
      if (hasPermission) {
        Logger.info('Permission already granted, no dialog needed');
        setState(() {
          _permissionGranted = true;
        });
        return; // Permission is granted, no need to show dialog
      }
      
      // Only show dialog if permission is not granted
      if (mounted) {
        _showPermissionDialog();
      }
    } catch (e, stack) {
      Logger.error('Error checking permission first', e, stack);
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }
  
  Future<void> _requestPermissionImmediately() async {
    try {
      Logger.info('Requesting microphone permission immediately...');
      
      // Try a simple, direct permission request first
      final result = await Permission.microphone.request();
      Logger.info('Direct permission request result: $result');
      
      // Check final status
      final finalStatus = await Permission.microphone.status;
      Logger.info('Final permission status: $finalStatus');
      
      if (finalStatus.isGranted) {
        Logger.info('Permission granted!');
        setState(() {
          _permissionGranted = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission granted!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        Logger.warning('Permission not granted: $finalStatus');
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (e, stack) {
      Logger.error('Error requesting permission immediately', e, stack);
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }
  
  Future<void> _checkPermission() async {
    final service = ref.read(voiceRecordingServiceProvider);
    final hasPermission = await service.checkPermission();
    
    Logger.info('Permission check result: $hasPermission');
    
    if (!hasPermission && mounted) {
      _showPermissionDialog();
    }
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Microphone access is required to record voice notes.\n\n'
          'The app has been added to your microphone permissions, but access is currently denied.\n\n'
          'To enable microphone access:\n'
          '1. Go to Settings > Privacy & Security > Microphone\n'
          '2. Find "Metanoia" in the list\n'
          '3. Turn on the microphone permission\n\n'
          'After enabling, return to the app and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Open iOS Settings
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _checkPermission();
            },
            child: const Text('Check Again'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _startRecording() async {
    try {
      final service = ref.read(voiceRecordingServiceProvider);
      
      final path = await service.startRecording();
      if (path != null) {
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDurationSeconds = 0;
          _liveTranscription = ''; // Reset live transcription
        });
        
        // Start live transcription if enabled
        if (_enableLiveTranscription) {
          _startLiveTranscription();
        }
      }
    } catch (e, stack) {
      Logger.error('Failed to start recording', e, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _startLiveTranscription() async {
    try {
      Logger.info('Starting live transcription...');
      
      final transcriptionService = ref.read(voiceTranscriptionServiceProvider);
      
      // Initialize speech recognition
      final initialized = await transcriptionService.initialize();
      if (!initialized) {
        Logger.warning('Live transcription not available');
        setState(() {
          _enableLiveTranscription = false;
          _liveTranscription = '';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live transcription unavailable. You can type manually or use Whisper API.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      Logger.info('Live transcription initialized successfully');
      
      // Start real-time transcription
      transcriptionService.transcribeLocalRealtime(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _liveTranscription = text;
            });
            Logger.info('Live transcription updated: ${text.length} characters');
          }
        },
        onError: (error) {
          Logger.error('Live transcription error', error, null);
          if (mounted) {
            setState(() {
              _liveTranscription = '';
              _enableLiveTranscription = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Live transcription error: $error'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        durationSeconds: VoiceRecordingService.maxDurationSeconds,
      );
      
      Logger.info('Live transcription started successfully');
    } catch (e, stack) {
      Logger.error('Failed to start live transcription', e, stack);
      setState(() {
        _enableLiveTranscription = false;
        _liveTranscription = '';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start live transcription: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      final service = ref.read(voiceRecordingServiceProvider);
      final transcriptionService = ref.read(voiceTranscriptionServiceProvider);
      
      // Stop live transcription
      if (_enableLiveTranscription) {
        await transcriptionService.stopListening();
      }
      
      setState(() => _isProcessing = true);
      
      final path = await service.stopRecording();
      if (path != null && mounted) {
        // Navigate to transcription review with live transcription
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceTranscriptionReviewPage(
              audioFilePath: path,
              durationSeconds: _recordingDurationSeconds,
              preTranscription: _liveTranscription.isNotEmpty ? _liveTranscription : null,
            ),
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('Failed to stop recording', e, stack);
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _cancelRecording() async {
    try {
      final service = ref.read(voiceRecordingServiceProvider);
      await service.cancelRecording();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, stack) {
      Logger.error('Failed to cancel recording', e, stack);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Voice Note'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isRecording
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Recording?'),
                      content: const Text(
                        'Are you sure you want to cancel this recording?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelRecording();
                          },
                          child: const Text('Yes, Cancel'),
                        ),
                      ],
                    ),
                  );
                }
              : () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing recording...'),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Permission status and request button (only show if permission not granted)
                    if (!_permissionGranted)
                      Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mic,
                            size: 48,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Microphone Permission Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The app has been added to your microphone permissions. If access is denied, go to Settings > Privacy & Security > Microphone to enable it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _requestPermissionImmediately,
                            icon: const Icon(Icons.mic),
                            label: const Text('Request Microphone Permission'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await openAppSettings();
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Open iOS Settings'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_permissionGranted) const SizedBox(height: 16),
                    // Voice recorder
                    Expanded(
                      child: VoiceNoteRecorder(
                        isRecording: _isRecording,
                        onStart: _startRecording,
                        onStop: _stopRecording,
                        onCancel: _cancelRecording,
                        maxDurationSeconds: VoiceRecordingService.maxDurationSeconds,
                        enableLiveTranscription: _enableLiveTranscription,
                        liveTranscription: _liveTranscription.isNotEmpty ? _liveTranscription : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

