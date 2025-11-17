import 'package:flutter/material.dart';
import '../../data/learning_loop.dart';

/// FEEDBACK Section - Outcome Comparison
/// Shows actual outcome, error signal, and prediction accuracy
class FeedbackSection extends StatelessWidget {
  final LearningLoop loop;
  final bool isEditing;
  final Function(LearningLoop)? onUpdate;
  final Function(bool)? onPredictionOutcome;

  const FeedbackSection({
    super.key,
    required this.loop,
    this.isEditing = false,
    this.onUpdate,
    this.onPredictionOutcome,
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
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.assessment, color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FEEDBACK - Outcome',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Actual Outcome
            Text(
              'Actual Outcome',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loop.outcome,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            
            // Error Signal
            if (loop.errorSignal != null && loop.errorSignal!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Error Signal (Prediction vs Reality)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  loop.errorSignal!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
            
            // Prediction Outcome Buttons
            const SizedBox(height: 20),
            Text(
              'Was your prediction correct?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildOutcomeButton(
                    context,
                    'Hit',
                    Icons.check_circle,
                    Colors.green,
                    true,
                    loop.predictionHit == true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOutcomeButton(
                    context,
                    'Miss',
                    Icons.cancel,
                    Colors.red,
                    false,
                    loop.predictionHit == false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool isHit,
    bool isSelected,
  ) {
    return OutlinedButton.icon(
      onPressed: onPredictionOutcome != null 
        ? () => onPredictionOutcome!(isHit)
        : null,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : color,
        backgroundColor: isSelected ? color : Colors.transparent,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}


