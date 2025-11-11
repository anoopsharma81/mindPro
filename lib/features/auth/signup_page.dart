import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../profile/profile_model.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});
  
  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
  
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Create initial profile
      if (userCredential.user != null) {
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();
        final displayName = '$firstName $lastName'.trim();
        
        final profile = Profile(
          uid: userCredential.user!.uid,
          displayName: displayName.isNotEmpty ? displayName : firstName.isNotEmpty ? firstName : lastName,
          gmcNumber: '', // GMC number removed from signup
          defaultYear: DateTime.now().year.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.saveProfile(profile);
      }
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0C2F37);
    const textColor = Color(0xFFF5F3F0);
    const buttonBackgroundColor = Colors.black;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: const TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: textColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                      prefixIcon: const Icon(Icons.person, color: textColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: const TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: textColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: textColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: textColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                      prefixIcon: const Icon(Icons.email, color: textColor),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: textColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: textColor),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: textColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: textColor),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: textColor),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Sign up button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackgroundColor,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sign in link
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}






