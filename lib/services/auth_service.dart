import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:final_project/models/user_profile.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // We've removed the mock/dummy fallback to ensure we only use real Firebase.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user profile already exists, if not create one
        final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (!doc.exists) {
          UserProfile userProfile = UserProfile(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            username: userCredential.user!.displayName ?? userCredential.user!.email?.split('@')[0] ?? 'User',
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(userCredential.user!.uid).set(userProfile.toFirestore());
        }
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      throw e.message ?? "An error occurred during Google sign in.";
    } catch (e) {
      debugPrint("Google Sign In failure: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, {String? username}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        debugPrint("User created in Auth: ${userCredential.user!.uid}. Attempting Firestore write...");
        try {
          UserProfile userProfile = UserProfile(
            uid: userCredential.user!.uid,
            email: email,
            username: username ?? email.split('@')[0],
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(userCredential.user!.uid).set(userProfile.toFirestore());
          debugPrint("Firestore write successful.");
        } catch (e) {
          // If Firestore fails, we LOG it but don't STOP the user.
          // The app can self-heal later when they save the questionnaire.
          debugPrint("NON-FATAL ERROR: Initial Firestore write denied. User can still proceed. Error: $e");
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      throw e.message ?? "An error occurred during sign up.";
    } catch (e) {
      debugPrint("Firebase unexpected failure: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      throw e.message ?? "An error occurred during sign in.";
    } catch (e) {
      debugPrint("Firebase unexpected failure: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google Sign Out error: $e");
    }
    await _auth.signOut();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        // If the document doesn't exist, try to create a basic one from Auth
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          return UserProfile(
            uid: uid,
            email: currentUser.email ?? '',
            username: currentUser.email?.split('@')[0],
            createdAt: DateTime.now(), // Fallback
          );
        }
      }
    } catch (e) {
      debugPrint("Firestore failed: $e");
    }
    return null;
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> updateQuestionnaireData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'questionnaireData': data,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore update failed: $e");
      rethrow;
    }
  }
}
