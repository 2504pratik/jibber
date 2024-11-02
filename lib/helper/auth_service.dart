import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google sign-in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled sign-in

      // Obtain the auth details from Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential and return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error in Google Sign-In: $e');
      return null;
    }
  }

  // Check if username exists and navigate
  Future<void> checkAndNavigate(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Check Firestore for username
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc['username'] != null) {
        // Username exists, navigate to HomeScreen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // No username, navigate to UsernameInputPage
        Navigator.pushReplacementNamed(context, '/username');
      }
    }
  }
}
