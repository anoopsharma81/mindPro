import 'package:flutter/material.dart';
import '../../data/learning_loop.dart';
import 'package:intl/intl.dart';

/// UPDATE RULE Section - Actionable Learning
/// Shows if-then rule, micro-practice, and spaced repetition schedule
class UpdateRuleSection extends StatelessWidget {
  final LearningLoop loop;
  final bool isEditing;
  final Function(LearningLoop)? onUpdate;

  const UpdateRuleSection({
    super.key,
    required this.loop,
    this.isEditing = false,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final nextReview = loop.getNextReviewDate();
    
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
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.auto_awesome, color: Colors.indigo.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'UPDATE RULE - Learning Integration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // If-Then Learning Rule
            Text(
              'If-Then Learning Rule',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade300, width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loop.ifThenRule,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Micro-Practice (48 hours)
            if (loop.microRep48h != null && loop.microRep48h!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Micro-Practice (Next 48 Hours)',
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
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.assignment, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loop.microRep48h!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Spaced Repetition Schedule
            if (loop.spacedPlanDays.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Spaced Repetition Schedule',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildSpacedRepetitionTimeline(context),
              
              // Next Review Info
              if (nextReview != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: loop.isReviewDue 
                      ? Colors.red.shade50 
                      : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: loop.isReviewDue 
                        ? Colors.red.shade300 
                        : Colors.green.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        loop.isReviewDue 
                          ? Icons.notification_important 
                          : Icons.schedule,
                        color: loop.isReviewDue 
                          ? Colors.red.shade700 
                          : Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loop.isReviewDue
                            ? 'Review is due now!'
                            : 'Next review: ${_formatDate(nextReview)} (${_getDaysUntil(nextReview)})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: loop.isReviewDue 
                              ? Colors.red.shade900 
                              : Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpacedRepetitionTimeline(BuildContext context) {
    return Row(
      children: [
        _buildTimelineNode(context, 'Today', true, true),
        ...loop.spacedPlanDays.asMap().entries.map((entry) {
          final index = entry.key;
          final days = entry.value;
          final isLast = index == loop.spacedPlanDays.length - 1;
          final reviewDate = loop.createdAt.add(Duration(days: days));
          final isPast = DateTime.now().isAfter(reviewDate);
          
          return Row(
            children: [
              _buildTimelineConnector(context),
              _buildTimelineNode(
                context,
                '${days}d',
                !isLast,
                isPast,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTimelineNode(BuildContext context, String label, bool hasNext, bool isPast) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isPast ? Colors.indigo.shade700 : Colors.indigo.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.indigo.shade700,
              width: 2,
            ),
          ),
          child: Center(
            child: isPast
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  label == 'Today' ? '•' : '',
                  style: TextStyle(
                    color: Colors.indigo.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isPast ? Colors.indigo.shade700 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      color: Colors.indigo.shade300,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reviewDay = DateTime(date.year, date.month, date.day);
    
    if (reviewDay == today) {
      return 'Today';
    } else if (reviewDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final days = date.difference(now).inDays;
    
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    if (days < 0) return 'overdue';
    return 'in $days days';
  }
}


