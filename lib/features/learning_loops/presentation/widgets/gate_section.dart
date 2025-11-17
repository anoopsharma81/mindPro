import 'package:flutter/material.dart';
import '../../data/learning_loop.dart';

/// GATE Section - Emotional & Attentional State
/// Shows focus level, emotional tone, and intensity
class GateSection extends StatelessWidget {
  final LearningLoop loop;
  final bool isEditing;
  final Function(LearningLoop)? onUpdate;

  const GateSection({
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
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lock_open, color: Colors.teal.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GATE - Emotional State',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Attention Level
            _buildMetric(
              context,
              'Focus Level',
              loop.attentionLevel,
              3,
              loop.attentionLabel,
              Colors.teal,
            ),
            const SizedBox(height: 16),
            
            // Emotion Valence
            _buildMetric(
              context,
              'Emotional Tone',
              loop.emotionValence + 3, // Shift to 0-6 for display
              6,
              loop.emotionValenceLabel,
              loop.emotionValence >= 0 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            
            // Emotion Arousal
            _buildMetric(
              context,
              'Emotional Intensity',
              loop.emotionArousal,
              3,
              loop.emotionArousalLabel,
              Colors.teal,
            ),
            
            // Context Note
            if (loop.contextNote != null && loop.contextNote!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Context',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  loop.contextNote!,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    int value,
    int max,
    String description,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$value/$max',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / max,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}


