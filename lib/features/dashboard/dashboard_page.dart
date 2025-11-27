import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../reflections/presentation/voice_note_flow_page.dart';
import '../reflections/presentation/widgets/document_source_selector.dart';
import '../reflections/presentation/reflection_from_document_page.dart';
import '../reflections/presentation/reflection_edit_page.dart';
import '../../services/api_service.dart';
import '../../core/logger.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isProcessing = false;
  bool _hasText = false;
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus != _isFocused) {
        setState(() {
          _isFocused = _searchFocusNode.hasFocus;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _createReflectionFromText(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final apiService = ApiService();
      final inputText = text.trim();
      Logger.info('Creating reflection from text input: "$inputText"');
      
      if (inputText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter some text to create a reflection'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Use the structureTranscription API (it works for any text input)
      Logger.info('Calling structureTranscription API with input: "$inputText"');
      final structured = await apiService.structureTranscription(
        transcription: inputText,
      );
      
      // Log the full response to debug
      Logger.info('API Response received: $structured');
      
      // Handle both response formats:
      // 1. Firebase function returns: { success: true, reflection: { title, what, ... } }
      // 2. Backend server returns: { title, what, soWhat, ... }
      final reflectionData = (structured['reflection'] as Map<String, dynamic>?) ?? structured;
      
      Logger.info('Reflection data extracted: $reflectionData');
      
      // Extract values with proper null checking
      final title = reflectionData['title'] as String?;
      final what = reflectionData['what'] as String?;
      final soWhat = reflectionData['soWhat'] as String?;
      final nowWhat = reflectionData['nowWhat'] as String?;
      final tags = reflectionData['tags'] as List?;
      final suggestedDomains = reflectionData['suggestedDomains'] as List?;
      
      Logger.info('Parsed values - title: "$title", what: "${what?.substring(0, what.length > 50 ? 50 : what.length)}..."');
      
      // Debug: Show what we received (in debug mode)
      Logger.info('=== API RESPONSE DEBUG ===');
      Logger.info('Input text: "$inputText"');
      Logger.info('Response title: "$title"');
      Logger.info('Response what: "${what?.substring(0, what.length > 100 ? 100 : what.length)}..."');
      Logger.info('Response soWhat: "${soWhat?.substring(0, soWhat.length > 50 ? 50 : soWhat.length)}..."');
      Logger.info('Response nowWhat: "${nowWhat?.substring(0, nowWhat.length > 50 ? 50 : nowWhat.length)}..."');
      Logger.info('Full response: $structured');
      Logger.info('Reflection data: $reflectionData');
      Logger.info('========================');
      
      // Validate that we got some data back
      // Accept the response if we have either a title or what field
      final hasValidContent = (title != null && title.isNotEmpty) || 
                              (what != null && what.isNotEmpty);
      
      if (!hasValidContent) {
        Logger.warning('API response appears invalid - no title or what field. Using input text directly.');
        Logger.warning('Full response was: $structured');
        // If API didn't return meaningful structured data, use the input text directly
        if (mounted) {
          initialReflectionDataHolder.setData(
            InitialReflectionData(
              title: inputText.length > 50 ? '${inputText.substring(0, 50)}...' : inputText,
              what: inputText,
              soWhat: '',
              nowWhat: '',
              tags: [],
              domains: null,
            ),
          );
          context.go('/reflections/new');
        }
        return;
      }
      
      // Combine what, soWhat, and nowWhat into single reflection text
      final reflectionParts = <String>[];
      if (what != null && what.isNotEmpty) reflectionParts.add(what);
      if (soWhat != null && soWhat.isNotEmpty) reflectionParts.add(soWhat);
      if (nowWhat != null && nowWhat.isNotEmpty) reflectionParts.add(nowWhat);
      final combinedReflection = reflectionParts.isNotEmpty 
          ? reflectionParts.join('\n\n')
          : inputText;
      
      Logger.info('AI structured reflection created - title: "${title ?? 'New Reflection'}", reflection length: ${combinedReflection.length}');
      
      // Use the title from API, or create one from input if not provided
      // Don't reject titles that match fallback values - they might be valid
      final finalTitle = title?.isNotEmpty == true 
          ? title!
          : (inputText.length > 50 ? '${inputText.substring(0, 50)}...' : inputText);
      
      // Set initial data in provider and navigate
      if (mounted) {
        initialReflectionDataHolder.setData(
          InitialReflectionData(
            title: finalTitle,
            what: combinedReflection,
            soWhat: '', // Empty - all content in 'what'
            nowWhat: '', // Empty - all content in 'what'
            tags: tags?.cast<String>() ?? [],
            domains: suggestedDomains?.cast<int>(),
          ),
        );
        
        context.go('/reflections/new');
      }
    } catch (e, stack) {
      Logger.error('Failed to create reflection from text', e, stack);
      if (mounted) {
        // Show detailed error to user
        final errorMessage = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create reflection: ${errorMessage.length > 100 ? '${errorMessage.substring(0, 100)}...' : errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Use text directly',
              textColor: Colors.white,
              onPressed: () {
                // Fallback: use input text directly
                initialReflectionDataHolder.setData(
                  InitialReflectionData(
                    title: text.trim().length > 50 ? '${text.trim().substring(0, 50)}...' : text.trim(),
                    what: text.trim(),
                    soWhat: '',
                    nowWhat: '',
                    tags: [],
                    domains: null,
                  ),
                );
                context.go('/reflections/new');
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _searchController.clear();
        });
      }
    }
  }
  
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
            color: const Color(0xFFF5F3F0).withValues(alpha: 0.2),
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
          color: color.withValues(alpha: 0.2),
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
        style: TextStyle(color: const Color(0xFFF5F3F0).withValues(alpha: 0.7)),
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
                      const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile?.displayName ?? user?.email ?? 'User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'notifications',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.settings,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_download,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Export',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
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
                      Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
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
                          color: const Color(0xFFF5F3F0).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _isFocused 
                                ? const Color(0xFFF5F3F0)
                                : const Color(0xFFF5F3F0).withValues(alpha: 0.3),
                            width: _isFocused ? 2 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          enabled: !_isProcessing,
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color(0xFFF5F3F0),
                            letterSpacing: 0.3,
                          ),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Type to create a reflection with AI...',
                            hintStyle: TextStyle(
                              color: const Color(0xFFF5F3F0).withValues(alpha: 0.6),
                            ),
                            filled: false,
                            prefixIcon: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFF5F3F0),
                                        ),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.psychology,
                                    color: const Color(0xFFF5F3F0).withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                            suffixIcon: _hasText && !_isProcessing
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFFF5F3F0),
                                      size: 20,
                                    ),
                                    onPressed: () => _createReflectionFromText(_searchController.text),
                                    tooltip: 'Create reflection',
                                  )
                                : !_isProcessing
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: const Color(0xFFF5F3F0).withValues(alpha: 0.6),
                                          size: 20,
                                        ),
                                        onPressed: () => _showCreationOptions(context),
                                        tooltip: 'More options',
                                      )
                                    : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty && !_isProcessing) {
                              _createReflectionFromText(value);
                            }
                          },
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
