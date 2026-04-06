import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:final_project/models/user_profile.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // We've removed the mock/dummy fallback to ensure we only use real Firebase.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
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
            createdAt: DateTime.now(), // Fallback
          );
        }
      }
    } catch (e) {
      debugPrint("Firestore failed: $e");
    }
    return null;
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
