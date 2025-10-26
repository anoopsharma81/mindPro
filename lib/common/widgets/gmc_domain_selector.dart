import 'package:flutter/material.dart';
import '../models/gmc_domain.dart';

/// Multi-select widget for GMC domains
class GmcDomainSelector extends StatelessWidget {
  final List<int> selectedDomains;
  final ValueChanged<List<int>> onChanged;
  
  const GmcDomainSelector({
    super.key,
    required this.selectedDomains,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GMC Domains',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Select which GMC Good Medical Practice domains this reflection addresses:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GmcDomain.values.map((domain) {
            final isSelected = selectedDomains.contains(domain.number);
            return FilterChip(
              label: Text(
                domain.shortName,
                style: const TextStyle(fontSize: 13),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newDomains = List<int>.from(selectedDomains);
                if (selected) {
                  newDomains.add(domain.number);
                } else {
                  newDomains.remove(domain.number);
                }
                newDomains.sort();
                onChanged(newDomains);
              },
              avatar: CircleAvatar(
                backgroundColor: isSelected ? domain.color : Colors.grey,
                child: Text(
                  domain.number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              selectedColor: domain.color.withOpacity(0.2),
              checkmarkColor: domain.color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Show selected domains with full names
        if (selectedDomains.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${selectedDomains.map((n) => GmcDomain.fromNumber(n).displayName).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Display widget for GMC domain chips (read-only)
class GmcDomainChips extends StatelessWidget {
  final List<int> domains;
  final bool compact;
  
  const GmcDomainChips({
    super.key,
    required this.domains,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (domains.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: domains.map((num) {
        final domain = GmcDomain.fromNumber(num);
        return Chip(
          label: Text(
            compact ? domain.number.toString() : domain.shortName,
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: domain.color.withOpacity(0.1),
          side: BorderSide(color: domain.color, width: 1),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}





