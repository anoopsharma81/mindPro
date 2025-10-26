import 'package:flutter/material.dart';
import '../utils/phi_detector.dart';

/// Dialog to warn users about potential PHI in their reflections
class PhiWarningDialog extends StatelessWidget {
  final List<String> detectedPhi;
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  
  const PhiWarningDialog({
    super.key,
    required this.detectedPhi,
    required this.onContinue,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    final warningMessage = PhiDetector.getWarningMessage(detectedPhi);
    
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: const Text('Patient Information Warning'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(warningMessage),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Data Protection Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Under GDPR and NHS Information Governance requirements, '
                    'reflections must not contain patient identifiable information. '
                    'This protects patient privacy and ensures compliance.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: onCancel,
          child: const Text('Review Text'),
        ),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('I\'ve Checked - Continue Anyway'),
        ),
      ],
    );
  }
  
  /// Show PHI warning dialog and return user's decision
  static Future<bool> show(
    BuildContext context,
    String text,
  ) async {
    final detected = PhiDetector.detectPhi(text);
    
    if (detected.isEmpty) {
      return true; // No PHI detected, safe to continue
    }
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhiWarningDialog(
        detectedPhi: detected,
        onContinue: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    ) ?? false;
  }
}

/// Inline PHI warning indicator (for real-time feedback)
class PhiIndicator extends StatelessWidget {
  final String text;
  final bool compact;
  
  const PhiIndicator({
    super.key,
    required this.text,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final level = PhiDetector.getWarningLevel(text);
    
    if (!level.shouldWarn) {
      return const SizedBox.shrink();
    }
    
    final color = _getColor(level, context);
    
    if (compact) {
      return Icon(
        Icons.warning_amber_rounded,
        color: color,
        size: 20,
      );
    }
    
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                level.description,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getColor(PhiWarningLevel level, BuildContext context) {
    switch (level) {
      case PhiWarningLevel.none:
        return Colors.green;
      case PhiWarningLevel.low:
        return Colors.orange;
      case PhiWarningLevel.medium:
        return Colors.deepOrange;
      case PhiWarningLevel.high:
        return Theme.of(context).colorScheme.error;
    }
  }
}





