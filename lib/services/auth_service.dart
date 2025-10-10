import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../core/logger.dart';

/// Authentication service wrapping Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Current user
  User? get currentUser => _auth.currentUser;
  
  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      Logger.error('Sign in with email failed', e, stack);
      rethrow;
    }
  }
  
  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      Logger.error('Sign up with email failed', e, stack);
      rethrow;
    }
  }
  
  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e, stack) {
      Logger.error('Sign in with Google failed', e, stack);
      rethrow;
    }
  }
  
  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Create an OAuth credential from the Apple credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      // Sign in to Firebase with the Apple credential
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e, stack) {
      Logger.error('Sign in with Apple failed', e, stack);
      rethrow;
    }
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stack) {
      Logger.error('Send password reset email failed', e, stack);
      rethrow;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e, stack) {
      Logger.error('Sign out failed', e, stack);
      rethrow;
    }
  }
  
  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e, stack) {
      Logger.error('Delete account failed', e, stack);
      rethrow;
    }
  }
}


