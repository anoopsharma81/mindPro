import 'package:flutter/material.dart';

/// Star rating widget for user feedback (1-5 stars)
class RatingWidget extends StatelessWidget {
  final int? currentRating;
  final ValueChanged<int>? onRatingChanged;
  final bool readOnly;
  final double size;
  
  const RatingWidget({
    super.key,
    this.currentRating,
    this.onRatingChanged,
    this.readOnly = false,
    this.size = 32.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!readOnly) ...[
          Text(
            'Rate this reflection',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'How helpful was the AI improvement?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isFilled = currentRating != null && starNumber <= currentRating!;
            
            return IconButton(
              onPressed: readOnly || onRatingChanged == null
                  ? null
                  : () => onRatingChanged!(starNumber),
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled 
                  ? Colors.amber 
                  : (readOnly ? Colors.grey : Theme.of(context).colorScheme.primary),
                size: size,
              ),
              tooltip: readOnly ? null : '$starNumber star${starNumber > 1 ? 's' : ''}',
            );
          }),
        ),
        if (currentRating != null && !readOnly) ...[
          const SizedBox(height: 8),
          Text(
            _getRatingLabel(currentRating!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
  
  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Not helpful';
      case 2:
        return 'Slightly helpful';
      case 3:
        return 'Moderately helpful';
      case 4:
        return 'Very helpful';
      case 5:
        return 'Extremely helpful';
      default:
        return '';
    }
  }
}





