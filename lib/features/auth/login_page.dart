import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
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
  
  // Google Sign-In disabled to prevent crashes - see GOOGLE_SIGNIN_FIX.md
  // Uncomment this method when Google Sign-In is fully configured
  /*
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google Sign-In failed. Please use email/password login instead.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  */
  
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0C2F37);
    const textColor = Color(0xFFF5F3F0);
    const buttonBackgroundColor = Colors.black;
    
    return Scaffold(
      backgroundColor: backgroundColor,
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
                  // Metanoia Logo
                  _MetanoiaLogo(textColor: textColor),
                  const SizedBox(height: 24),
                  Text(
                    'Metanoia',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reflective intelligence',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Email field
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
                  
                  // Password field
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
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Sign in button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
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
                            'Sign In',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  
                  // Optional: Google sign in (commented out to prevent crashes)
                  // Uncomment when Google Sign-In is fully configured
                  /*
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 16),
                  */
                  
                  // Sign up link
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text(
                      'Don\'t have an account? Sign up',
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

/// Creative Metanoia Logo Widget
/// Represents reflection, transformation, and intelligence
class _MetanoiaLogo extends StatelessWidget {
  final Color textColor;
  
  const _MetanoiaLogo({required this.textColor});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  textColor.withOpacity(0.15),
                  textColor.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
          // Main circle with gradient border
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  textColor.withOpacity(0.25),
                  textColor.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: textColor.withOpacity(0.4),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: textColor.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Brain icon at top (thinking/reflection)
                Positioned(
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: textColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: textColor.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                ),
                // Stylized "M" letter (Metanoia)
                Positioned(
                  bottom: 22,
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                      shadows: [
                        Shadow(
                          color: textColor.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Reflection indicator (horizontal line)
                Positioned(
                  left: 25,
                  right: 25,
                  bottom: 30,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          textColor.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Accent dots (decorative)
          Positioned(
            left: 15,
            top: 45,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor.withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 45,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


