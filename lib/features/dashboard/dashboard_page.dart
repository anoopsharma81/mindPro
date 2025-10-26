import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final availableYears = ref.watch(availableYearsProvider);
    
    // Update selected year when profile loads
    ref.listen(currentProfileProvider, (previous, next) {
      next.whenData((profile) {
        if (profile?.defaultYear != null) {
          ref.read(selectedYearProvider.notifier).setYear(profile!.defaultYear);
        }
      });
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metanoia'),
        actions: [
          // Year selector
          availableYears.when(
            data: (years) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: selectedYear,
                underline: const SizedBox(),
                isDense: true,
                items: years.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (year) {
                  if (year != null) {
                    ref.read(selectedYearProvider.notifier).setYear(year);
                  }
                },
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
          
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
          
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            profileAsync.when(
              data: (profile) => Text(
                profile != null 
                  ? 'Welcome, ${profile.displayName}'
                  : 'Welcome, ${user?.email ?? "User"}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => Text(
                'Welcome, ${user?.email ?? "User"}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Transform learning into understanding and reflection',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'AI-Powered',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // AI Feature Highlight
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade50,
                    Colors.blue.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.blue.shade400],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Reflection Coach',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.purple.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transform good reflections into excellent ones with AI-powered suggestions',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick actions
            Wrap(spacing: 12, runSpacing: 12, children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/reflections'),
                icon: const Icon(Icons.psychology),
                label: const Text('Reflections'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/cpd'),
                icon: const Icon(Icons.school),
                label: const Text('CPD'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/export'),
                icon: const Icon(Icons.file_download),
                label: const Text('Export'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/profile'),
                icon: const Icon(Icons.person),
                label: const Text('Profile'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
