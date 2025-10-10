import 'package:flutter/material.dart';

/// Empty state widget for when lists have no items
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state specifically for reflections
class EmptyReflectionsState extends StatelessWidget {
  final VoidCallback onCreateFirst;
  
  const EmptyReflectionsState({
    super.key,
    required this.onCreateFirst,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.psychology_outlined,
      title: 'No Reflections Yet',
      message: 'Start your reflective practice journey.\n\n'
          'Reflections help you learn from experiences and '
          'demonstrate professional development for your NHS appraisal.',
      actionLabel: 'Create First Reflection',
      onAction: onCreateFirst,
    );
  }
}

/// Empty state specifically for CPD
class EmptyCpdState extends StatelessWidget {
  final VoidCallback onCreateFirst;
  
  const EmptyCpdState({
    super.key,
    required this.onCreateFirst,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.school_outlined,
      title: 'No CPD Activities Yet',
      message: 'Record your continuing professional development.\n\n'
          'Track courses, teaching, audits, and reading to demonstrate '
          'your commitment to lifelong learning.',
      actionLabel: 'Add First CPD Activity',
      onAction: onCreateFirst,
    );
  }
}

/// Empty state for search results
class EmptySearchState extends StatelessWidget {
  final String searchQuery;
  
  const EmptySearchState({
    super.key,
    required this.searchQuery,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'No items match "$searchQuery".\n\n'
          'Try different search terms or clear the search.',
    );
  }
}

/// Empty state for filtered lists
class EmptyFilterState extends StatelessWidget {
  final VoidCallback onClearFilters;
  
  const EmptyFilterState({
    super.key,
    required this.onClearFilters,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.filter_alt_off,
      title: 'No Items Match Filters',
      message: 'Try adjusting your filters to see more results.',
      actionLabel: 'Clear Filters',
      onAction: onClearFilters,
    );
  }
}

