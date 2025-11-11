import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavButton(
                icon: Icons.home,
                label: 'Home',
                onTap: () => context.go('/'),
              ),
              _NavButton(
                icon: Icons.psychology,
                label: 'Reflections',
                onTap: () => context.go('/reflections'),
              ),
              _NavButton(
                icon: Icons.school,
                label: 'My CPD',
                onTap: () => context.go('/cpd'),
              ),
              _NavButton(
                icon: Icons.search,
                label: 'Search',
                onTap: () {
                  // TODO: Implement search functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

