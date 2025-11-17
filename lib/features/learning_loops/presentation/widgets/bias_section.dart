import 'package:flutter/material.dart';
import '../../data/learning_loop.dart';

/// BIAS REFLECTION Section - Cognitive Biases
/// Shows identified biases and counter-strategies
class BiasSection extends StatelessWidget {
  final LearningLoop loop;
  final bool isEditing;
  final Function(LearningLoop)? onUpdate;

  const BiasSection({
    super.key,
    required this.loop,
    this.isEditing = false,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.psychology, color: Colors.pink.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'BIAS REFLECTION - Cognitive Biases',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Cognitive Biases Identified
            Text(
              'Cognitive Biases Identified',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            if (loop.biases.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.grey.shade600, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'No significant biases identified',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: loop.biases.map((bias) => Chip(
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.pink.shade700,
                    size: 16,
                  ),
                  label: Text(_formatBiasName(bias)),
                  backgroundColor: Colors.pink.shade50,
                  labelStyle: TextStyle(
                    color: Colors.pink.shade900,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                )).toList(),
              ),
            
            // Counter Strategies
            if (loop.counterMoves.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Counter Strategies',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              ...loop.counterMoves.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: Colors.pink.shade700,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBiasName(String bias) {
    // Convert snake_case to Title Case
    return bias
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
  }
}


