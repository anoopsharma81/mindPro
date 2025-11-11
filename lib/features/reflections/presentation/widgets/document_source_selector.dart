import 'package:flutter/material.dart';

/// Bottom sheet for selecting document/photo source
class DocumentSourceSelector extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseGallery;
  final VoidCallback onUploadDocument;

  const DocumentSourceSelector({
    super.key,
    required this.onTakePhoto,
    required this.onChooseGallery,
    required this.onUploadDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create from Document/Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFF5F3F0),
                      ),
                    ),
                    Text(
                      'AI will extract and structure your reflection',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFF5F3F0).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Take Photo Option
          _buildOption(
            context,
            icon: Icons.camera_alt,
            iconColor: Colors.purple.shade400,
            title: 'Take Photo',
            subtitle: 'Capture notes, whiteboard, or any document',
            onTap: () {
              Navigator.pop(context);
              onTakePhoto();
            },
          ),
          const SizedBox(height: 12),

          // Gallery Option
          _buildOption(
            context,
            icon: Icons.photo_library,
            iconColor: Colors.blue.shade400,
            title: 'Choose from Gallery',
            subtitle: 'Select an existing photo from your device',
            onTap: () {
              Navigator.pop(context);
              onChooseGallery();
            },
          ),
          const SizedBox(height: 12),

          // Document Upload Option
          _buildOption(
            context,
            icon: Icons.description,
            iconColor: Colors.green.shade400,
            title: 'Upload Document',
            subtitle: 'PDF, Word (.docx), Text, or Image',
            onTap: () {
              Navigator.pop(context);
              onUploadDocument();
            },
          ),
          const SizedBox(height: 16),

          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child:           Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFF5F3F0).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFF5F3F0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFF5F3F0).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: const Color(0xFFF5F3F0).withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the bottom sheet
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseGallery,
    required VoidCallback onUploadDocument,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentSourceSelector(
        onTakePhoto: onTakePhoto,
        onChooseGallery: onChooseGallery,
        onUploadDocument: onUploadDocument,
      ),
    );
  }
}

