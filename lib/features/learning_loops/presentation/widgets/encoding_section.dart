import 'package:flutter/material.dart';
import '../../data/learning_loop.dart';

/// ENCODING Section - Pattern Recognition
/// Shows identified pattern, prior knowledge links, and tags
class EncodingSection extends StatelessWidget {
  final LearningLoop loop;
  final bool isEditing;
  final Function(LearningLoop)? onUpdate;

  const EncodingSection({
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
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.extension, color: Colors.purple.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ENCODING - Pattern Recognition',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Pattern Name
            Text(
              'Pattern Identified',
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
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.purple.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loop.patternName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Links to Prior Knowledge
            if (loop.priorKnowledgeLinks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Links to Prior Knowledge',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              ...loop.priorKnowledgeLinks.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.link, color: Colors.purple.shade400, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        link,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            // Tags
            if (loop.chunkTags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Memory Tags',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: loop.chunkTags.map((tag) => Chip(
                  label: Text('#$tag'),
                  backgroundColor: Colors.purple.shade50,
                  labelStyle: TextStyle(
                    color: Colors.purple.shade900,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


