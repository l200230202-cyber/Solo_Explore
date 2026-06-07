import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  /// Returns ID token if successful, null if cancelled
  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      developer.log('Google Sign In Error: $e', name: 'SocialAuth');
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      developer.log('Google Sign Out Error: $e', name: 'SocialAuth');
    }
  }

  /// Sign in with Facebook
  /// Returns access token if successful, null if cancelled
  static Future<String?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        return result.accessToken?.token;
      } else if (result.status == LoginStatus.cancelled) {
        developer.log('Facebook login cancelled by user', name: 'SocialAuth');
        return null;
      } else {
        developer.log('Facebook login failed: ${result.message}', name: 'SocialAuth');
        return null;
      }
    } catch (e) {
      developer.log('Facebook Login Error: $e', name: 'SocialAuth');
      return null;
    }
  }

  /// Sign out from Facebook
  static Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      developer.log('Facebook Sign Out Error: $e', name: 'SocialAuth');
    }
  }

  /// Sign out from all social providers
  static Future<void> signOutAll() async {
    await signOutGoogle();
    await signOutFacebook();
  }
}
