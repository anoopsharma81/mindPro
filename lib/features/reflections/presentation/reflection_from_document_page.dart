import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/document_extraction_service.dart';
import '../../../core/logger.dart';
import 'widgets/ai_processing_indicator.dart';
import 'ai_draft_review_page.dart';

/// Coordinator page for creating reflection from document/photo
class ReflectionFromDocumentPage extends ConsumerStatefulWidget {
  final String sourceType; // "camera", "gallery", or "document"

  const ReflectionFromDocumentPage({
    super.key,
    required this.sourceType,
  });

  @override
  ConsumerState<ReflectionFromDocumentPage> createState() =>
      _ReflectionFromDocumentPageState();
}

class _ReflectionFromDocumentPageState
    extends ConsumerState<ReflectionFromDocumentPage> {
  bool _isProcessing = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    // Start the flow immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFlow();
    });
  }

  Future<void> _startFlow() async {
    try {
      switch (widget.sourceType) {
        case 'camera':
          await _takePhoto();
          break;
        case 'gallery':
          await _chooseFromGallery();
          break;
        case 'document':
          await _uploadDocument();
          break;
        default:
          throw Exception('Unknown source type: ${widget.sourceType}');
      }
    } catch (e, stack) {
      Logger.error('Flow start failed', e, stack);
      _handleError(e.toString());
    }
  }

  Future<void> _takePhoto() async {
    // Check camera permission (skip on web - not supported)
    if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        _handleError('Camera permission is required to take photos');
        return;
      }
    }

    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) {
      // User cancelled
      if (mounted) Navigator.pop(context);
      return;
    }

    // On web, use bytes; on mobile, use File
    if (kIsWeb) {
      final bytes = await photo.readAsBytes();
      await _processBytes(bytes, photo.name, 'photo');
    } else {
      await _processFile(File(photo.path), 'photo');
    }
  }

  Future<void> _chooseFromGallery() async {
    // Check photo library permission (skip on web - not supported)
    if (!kIsWeb) {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        _handleError('Photo library permission is required');
        return;
      }
    }

    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (photo == null) {
      // User cancelled
      if (mounted) Navigator.pop(context);
      return;
    }

    // On web, use bytes; on mobile, use File
    if (kIsWeb) {
      final bytes = await photo.readAsBytes();
      await _processBytes(bytes, photo.name, 'gallery');
    } else {
      await _processFile(File(photo.path), 'gallery');
    }
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      withData: kIsWeb, // On web, we need bytes
    );

    if (result == null || result.files.isEmpty) {
      // User cancelled
      if (mounted) Navigator.pop(context);
      return;
    }

    final platformFile = result.files.first;

    // On web, use bytes; on mobile, use File
    if (kIsWeb) {
      final bytes = platformFile.bytes;
      if (bytes == null) {
        _handleError('Could not read file data');
        return;
      }
      await _processBytes(bytes, platformFile.name, 'document');
    } else {
      final filePath = platformFile.path;
      if (filePath == null) {
        _handleError('Could not read file');
        return;
      }
      await _processFile(File(filePath), 'document');
    }
  }

  Future<void> _processFile(File file, String sourceType) async {
    setState(() {
      _isProcessing = true;
      _isCancelled = false;
    });

    try {
      final extractionService = ref.read(documentExtractionServiceProvider);
      
      // Check if cancelled before starting
      if (_isCancelled) {
        Logger.info('Process cancelled by user');
        return;
      }
      
      // Extract based on type
      final ExtractionResult result;
      final String? sourceUrl;
      
      if (sourceType == 'document') {
        result = await extractionService.extractFromDocument(file);
        sourceUrl = null; // Will be set by service during upload
      } else {
        result = await extractionService.extractFromPhoto(file);
        sourceUrl = null; // Will be set by service during upload
      }

      // Check if cancelled after extraction
      if (_isCancelled) {
        Logger.info('Process cancelled by user after extraction');
        return;
      }

      // Navigate to review page
      if (mounted && !_isCancelled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AiDraftReviewPage(
              extractionResult: result,
              sourceType: sourceType,
              sourceUrl: sourceUrl,
            ),
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('File processing failed', e, stack);
      if (!_isCancelled) {
      _handleError('AI extraction failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _cancelProcess() {
    setState(() {
      _isCancelled = true;
      _isProcessing = false;
    });
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _processBytes(Uint8List bytes, String filename, String sourceType) async {
    setState(() {
      _isProcessing = true;
      _isCancelled = false;
    });

    try {
      final extractionService = ref.read(documentExtractionServiceProvider);
      
      // Check if cancelled before starting
      if (_isCancelled) {
        Logger.info('Process cancelled by user');
        return;
      }
      
      // Extract based on type
      final ExtractionResult result;
      final String? sourceUrl;
      
      if (sourceType == 'document') {
        result = await extractionService.extractFromDocumentBytes(bytes, filename);
        sourceUrl = null; // Will be set by service during upload
      } else {
        result = await extractionService.extractFromPhotoBytes(bytes, filename);
        sourceUrl = null; // Will be set by service during upload
      }

      // Check if cancelled after extraction
      if (_isCancelled) {
        Logger.info('Process cancelled by user after extraction');
        return;
      }

      // Navigate to review page
      if (mounted && !_isCancelled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AiDraftReviewPage(
              extractionResult: result,
              sourceType: sourceType,
              sourceUrl: sourceUrl,
            ),
          ),
        );
      }
    } catch (e, stack) {
      Logger.error('Bytes processing failed', e, stack);
      
      // Don't show error if user cancelled
      if (!_isCancelled) {
        // Provide helpful message for common errors
        String errorMessage;
        final errorStr = e.toString().toLowerCase();
        
        if (errorStr.contains('retry-limit-exceeded') || 
            errorStr.contains('storage')) {
          errorMessage = 'Firebase Storage is not enabled.\n\n'
              'Please ask your administrator to:\n'
              '1. Go to Firebase Console > Storage\n'
              '2. Click "Get Started"\n'
              '3. Deploy storage rules\n\n'
              'For now, you can create reflections manually.';
        } else if (errorStr.contains('network') || errorStr.contains('connection') || errorStr.contains('timeout')) {
          errorMessage = 'Network error or timeout. Please check your internet connection and try again.';
        } else {
          errorMessage = 'AI extraction failed: ${e.toString()}';
        }
        
        _handleError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleError(String error) {
    setState(() {
      _isProcessing = false;
    });

    // Show error dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close this page
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _startFlow(); // Retry
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return AiProcessingOverlay(
        message: 'AI is analyzing your content...',
        steps: const [
          'Uploading file...',
          'Extracting key information',
          'Identifying learning moments',
          'Structuring reflection',
          'Suggesting GMC domains',
        ],
        onCancel: _cancelProcess,
      );
    }

    // This should rarely be visible since we navigate immediately
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reflection'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

