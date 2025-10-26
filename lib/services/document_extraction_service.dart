import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/logger.dart';
import '../features/auth/auth_provider.dart';
import 'auth_service.dart';
import 'api_service.dart';

/// Response from AI extraction API
class ExtractionResult {
  final String title;
  final String what;
  final String soWhat;
  final String nowWhat;
  final List<String> tags;
  final List<int> suggestedDomains;
  final double confidence;
  final String? extractedText;

  ExtractionResult({
    required this.title,
    required this.what,
    required this.soWhat,
    required this.nowWhat,
    required this.tags,
    required this.suggestedDomains,
    required this.confidence,
    this.extractedText,
  });

  factory ExtractionResult.fromJson(Map<String, dynamic> json) {
    final reflection = json['reflection'] as Map<String, dynamic>;
    final metadata = json['metadata'] as Map<String, dynamic>?;
    
    return ExtractionResult(
      title: reflection['title'] as String? ?? 'Untitled Reflection',
      what: reflection['what'] as String? ?? '',
      soWhat: reflection['soWhat'] as String? ?? '',
      nowWhat: reflection['nowWhat'] as String? ?? '',
      tags: (reflection['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      suggestedDomains: (reflection['suggestedDomains'] as List<dynamic>?)?.cast<int>() ?? [],
      confidence: (reflection['confidence'] as num?)?.toDouble() ?? 0.0,
      extractedText: metadata?['extractedText'] as String?,
    );
  }
}

/// Service for handling document/photo extraction and AI generation
class DocumentExtractionService {
  final AuthService _authService;
  final ApiService _apiService;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentExtractionService(this._authService, this._apiService);

  /// Upload file to Firebase Storage and return URL
  Future<String> _uploadFile(File file, String sourceType) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final path = 'users/${user.uid}/extractions/$sourceType-$timestamp.$extension';

    Logger.info('Uploading file to: $path');
    
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    Logger.info('File uploaded successfully: $downloadUrl');
    return downloadUrl;
  }

  /// Upload bytes to Firebase Storage and return URL (for web compatibility)
  Future<String> _uploadBytes(Uint8List bytes, String sourceType, String extension) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'users/${user.uid}/extractions/$sourceType-$timestamp.$extension';

    Logger.info('Uploading bytes to: $path');
    
    final ref = _storage.ref().child(path);
    
    // Set shorter timeout to fail faster (10 seconds instead of default 120)
    final metadata = SettableMetadata(
      contentType: _getContentType(extension),
      customMetadata: {'uploadedAt': timestamp.toString()},
    );
    
    // Upload with timeout
    final uploadTask = ref.putData(bytes, metadata);
    
    // Wait with timeout (10 seconds max)
    final snapshot = await uploadTask.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        uploadTask.cancel();
        throw Exception('Upload timed out after 10 seconds. Please check your internet connection.');
      },
    );
    
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    Logger.info('Bytes uploaded successfully: $downloadUrl');
    return downloadUrl;
  }
  
  /// Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// Extract reflection from photo
  Future<ExtractionResult> extractFromPhoto(File photoFile) async {
    try {
      Logger.info('Starting photo extraction');
      
      // Upload photo to Firebase Storage
      final photoUrl = await _uploadFile(photoFile, 'photo');
      
      // Call backend API for extraction
      final result = await _apiService.extractFromDocument(
        photoUrl: photoUrl,
        source: 'photo',
        mimeType: 'image/jpeg',
      );

      Logger.info('Photo extraction successful');
      return ExtractionResult.fromJson(result);
    } catch (e, stack) {
      Logger.error('Photo extraction failed', e, stack);
      rethrow;
    }
  }

  /// Extract reflection from photo bytes (for web)
  Future<ExtractionResult> extractFromPhotoBytes(Uint8List bytes, String filename) async {
    try {
      Logger.info('Starting photo extraction from bytes');
      
      // Determine extension from filename
      final extension = filename.split('.').last.toLowerCase();
      
      // Upload photo bytes to Firebase Storage
      final photoUrl = await _uploadBytes(bytes, 'photo', extension);
      
      // Call backend API for extraction
      final result = await _apiService.extractFromDocument(
        photoUrl: photoUrl,
        source: 'photo',
        mimeType: 'image/$extension',
      );

      Logger.info('Photo extraction from bytes successful');
      return ExtractionResult.fromJson(result);
    } catch (e, stack) {
      Logger.error('Photo extraction from bytes failed', e, stack);
      rethrow;
    }
  }

  /// Extract reflection from document (PDF, Word, etc.)
  Future<ExtractionResult> extractFromDocument(File documentFile) async {
    try {
      Logger.info('Starting document extraction');
      
      // Upload document to Firebase Storage
      final documentUrl = await _uploadFile(documentFile, 'document');
      
      // Determine MIME type
      final extension = documentFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);
      
      // Call backend API for extraction
      final result = await _apiService.extractFromDocument(
        photoUrl: documentUrl,
        source: 'document',
        mimeType: mimeType,
      );

      Logger.info('Document extraction successful');
      return ExtractionResult.fromJson(result);
    } catch (e, stack) {
      Logger.error('Document extraction failed', e, stack);
      rethrow;
    }
  }

  /// Extract reflection from document bytes (for web)
  Future<ExtractionResult> extractFromDocumentBytes(Uint8List bytes, String filename) async {
    try {
      Logger.info('Starting document extraction from bytes');
      
      // Determine extension and MIME type from filename
      final extension = filename.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);
      
      // Upload document bytes to Firebase Storage
      final documentUrl = await _uploadBytes(bytes, 'document', extension);
      
      // Call backend API for extraction
      final result = await _apiService.extractFromDocument(
        photoUrl: documentUrl,
        source: 'document',
        mimeType: mimeType,
      );

      Logger.info('Document extraction from bytes successful');
      return ExtractionResult.fromJson(result);
    } catch (e, stack) {
      Logger.error('Document extraction from bytes failed', e, stack);
      rethrow;
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Delete uploaded file from Firebase Storage (cleanup)
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      Logger.info('File deleted: $fileUrl');
    } catch (e, stack) {
      Logger.error('Failed to delete file', e, stack);
      // Don't rethrow - deletion is best-effort
    }
  }
}

/// Provider for DocumentExtractionService
final documentExtractionServiceProvider = Provider<DocumentExtractionService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final apiService = ApiService();
  return DocumentExtractionService(authService, apiService);
});

