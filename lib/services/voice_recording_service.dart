import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/logger.dart';
import '../features/auth/auth_provider.dart';
import 'auth_service.dart';

/// Service for recording voice notes
class VoiceRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final AuthService _authService;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  static const int maxDurationSeconds = 180; // 3 minutes
  
  VoiceRecordingService(this._authService);
  
  /// Check if microphone permission is granted
  Future<bool> checkPermission() async {
    try {
      // Use the record package's built-in permission check as primary
      final hasPermission = await _recorder.hasPermission();
      Logger.info('Record package permission check: $hasPermission');
      
      if (hasPermission) {
        return true;
      }
      
      // If record package says no permission, try permission_handler as backup
      final status = await Permission.microphone.status;
      Logger.info('Permission handler status: $status');
      
      if (status.isGranted) {
        return true;
      }
      
      // For denied or other statuses, return false (don't request again)
      Logger.warning('Microphone permission not granted: $status');
      return false;
    } catch (e, stack) {
      Logger.error('Error checking microphone permission', e, stack);
      return false;
    }
  }
  
  /// Start recording
  Future<String?> startRecording() async {
    try {
      // Web is not fully supported for voice recording
      if (kIsWeb) {
        throw UnsupportedError('Voice recording is not available on web. Please use the mobile app.');
      }
      
      // Check permission using record package first
      final hasPermission = await _recorder.hasPermission();
      Logger.info('Record package permission for recording: $hasPermission');
      
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }
      
      // Check if already recording
      if (await _recorder.isRecording()) {
        Logger.warning('Already recording');
        return null;
      }
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${tempDir.path}/voice_note_$timestamp.m4a';
      
      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      
      Logger.info('Recording started: $path');
      return path;
    } catch (e, stack) {
      Logger.error('Failed to start recording', e, stack);
      rethrow;
    }
  }
  
  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      if (!await _recorder.isRecording()) {
        Logger.warning('Not recording');
        return null;
      }
      
      final path = await _recorder.stop();
      Logger.info('Recording stopped: $path');
      return path;
    } catch (e, stack) {
      Logger.error('Failed to stop recording', e, stack);
      rethrow;
    }
  }
  
  /// Cancel recording and delete the file
  Future<void> cancelRecording() async {
    try {
      final path = await stopRecording();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          Logger.info('Recording cancelled and deleted: $path');
        }
      }
    } catch (e, stack) {
      Logger.error('Failed to cancel recording', e, stack);
      rethrow;
    }
  }
  
  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }
  
  /// Upload recorded audio to Firebase Storage
  Future<String> uploadAudio(String filePath) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Not authenticated');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'users/${user.uid}/audio/voice_note_$timestamp.m4a';
      
      Logger.info('Uploading audio to: $storagePath');
      
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      Logger.info('Audio uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e, stack) {
      Logger.error('Failed to upload audio', e, stack);
      rethrow;
    }
  }
  
  /// Delete temporary audio file
  Future<void> deleteTemporaryFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        Logger.info('Temporary file deleted: $filePath');
      }
    } catch (e, stack) {
      Logger.error('Failed to delete temporary file', e, stack);
      // Don't rethrow - deletion is best-effort
    }
  }
  
  /// Get audio duration in seconds
  Future<int> getAudioDuration(String filePath) async {
    try {
      // For now, return 0 and let the caller track duration
      // In a real implementation, you'd use a package like audioplayers
      // to get the actual duration from the file
      return 0;
    } catch (e, stack) {
      Logger.error('Failed to get audio duration', e, stack);
      return 0;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _recorder.dispose();
  }
}

/// Provider for VoiceRecordingService
final voiceRecordingServiceProvider = Provider<VoiceRecordingService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return VoiceRecordingService(authService);
});

