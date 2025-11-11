import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../reflections/presentation/voice_note_flow_page.dart';
import '../reflections/presentation/widgets/document_source_selector.dart';
import '../reflections/presentation/reflection_from_document_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  void _showCreationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0C2F37),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: const Color(0xFFF5F3F0).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Reflection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5F3F0),
              ),
            ),
            const SizedBox(height: 16),
            
            // Manual entry option
            _buildOption(
              context: sheetContext,
              icon: Icons.edit,
              title: 'Write Manually',
              subtitle: 'Type your reflection',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(sheetContext);
                context.go('/reflections/new');
              },
            ),
            const Divider(color: Color(0xFFF5F3F0), height: 1),
            
            // Voice note option
            _buildOption(
              context: sheetContext,
              icon: Icons.mic,
              title: 'Record Voice Note',
              subtitle: 'Speak and transcribe',
              color: Colors.red,
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceNoteFlowPage(),
                  ),
                );
              },
            ),
            const Divider(color: Color(0xFFF5F3F0), height: 1),
            
            // Document/Photo extraction option
            _buildOption(
              context: sheetContext,
              icon: Icons.auto_awesome,
              title: 'Extract from Document',
              subtitle: 'PDF, Word, Image, or Text',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(sheetContext);
                DocumentSourceSelector.show(
                  context,
                  onTakePhoto: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'camera',
                        ),
                      ),
                    );
                  },
                  onChooseGallery: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'gallery',
                        ),
                      ),
                    );
                  },
                  onUploadDocument: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReflectionFromDocumentPage(
                          sourceType: 'document',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFFF5F3F0)),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: const Color(0xFFF5F3F0).withOpacity(0.7)),
      ),
      onTap: onTap,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    
    // Update selected year when profile loads
    ref.listen(currentProfileProvider, (previous, next) {
      next.whenData((profile) {
        if (profile?.defaultYear != null) {
          ref.read(selectedYearProvider.notifier).setYear(profile!.defaultYear);
        }
      });
    });
    
    return Scaffold(
      backgroundColor: const Color(0xFF0C2F37),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2F37),
        elevation: 0,
        actions: [
          // Profile menu with avatar
          profileAsync.when(
            data: (profile) => PopupMenuButton<String>(
              offset: const Offset(0, 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: profile?.displayName.isNotEmpty == true
                    ? Text(
                        profile!.displayName.split(' ').map((n) => n[0]).take(2).join().toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile?.displayName ?? user?.email ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'notifications',
                  child: Row(
                    children: [
                      Icon(Icons.notifications),
                      SizedBox(width: 12),
                      Text('Notifications'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download),
                      SizedBox(width: 12),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Sign Out', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'profile') {
                  context.go('/profile');
                } else if (value == 'notifications') {
                  // TODO: Implement notifications page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                } else if (value == 'settings') {
                  context.go('/settings');
                } else if (value == 'export') {
                  context.go('/export');
                } else if (value == 'logout') {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
            ),
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center search bar vertically with greeting above
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Centered greeting
                      profileAsync.when(
                        data: (profile) {
                          String firstName = 'User';
                          if (profile != null && profile.displayName.isNotEmpty) {
                            firstName = profile.displayName.split(' ').first;
                          } else if (user?.email != null) {
                            firstName = user!.email!.split('@').first;
                          }
                          return Text(
                            'Hello, $firstName',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFFF5F3F0), // Pearl white
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => Text(
                          'Hello, ${user?.email?.split('@').first ?? "User"}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFFF5F3F0), // Pearl white
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 64),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3F0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFF5F3F0).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => _showCreationOptions(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    color: const Color(0xFFF5F3F0).withOpacity(0.6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Start reflecting...',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: const Color(0xFFF5F3F0).withOpacity(0.6),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F3F0).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Color(0xFFF5F3F0),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
