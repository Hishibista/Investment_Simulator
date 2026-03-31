import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:final_project/models/user_profile.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  bool get _isFirebaseUsable {
    try {
      final app = Firebase.app();
      // If we are using the dummy key from firebase_options.dart, 
      // treat Firebase as unusable so we fall back to local mode.
      return app.options.apiKey != 'dummy-api-key';
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth => _isFirebaseUsable ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => _isFirebaseUsable ? FirebaseFirestore.instance : null;

  // Mock user for local testing if Firebase is missing
  static User? _mockUser;

  Stream<User?> get authStateChanges {
    if (_isFirebaseUsable) {
      return _auth!.authStateChanges();
    } else {
      // Mock stream for local development
      return Stream.value(_mockUser);
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    if (_isFirebaseUsable) {
      try {
        UserCredential userCredential = await _auth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (userCredential.user != null) {
          UserProfile userProfile = UserProfile(
            uid: userCredential.user!.uid,
            email: email,
            createdAt: DateTime.now(),
          );
          await _firestore!.collection('users').doc(userCredential.user!.uid).set(userProfile.toFirestore());
        }
        return userCredential;
      } on FirebaseAuthException catch (e) {
        throw e.message ?? "An error occurred during sign up.";
      } catch (e) {
        // If Firebase fails unexpectedly, fall back to mock
        debugPrint("Firebase failed, falling back to mock: $e");
      }
    }
    
    // Fallback Mock persistence using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'uid': 'mock-user-123',
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString('mock_user', jsonEncode(userData));
    
    debugPrint("MOCK: Created account for $email");
    return null; 
  }

  Future<void> signOut() async {
    if (_isFirebaseUsable) {
      await _auth!.signOut();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_user');
      _mockUser = null;
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (_isFirebaseUsable) {
      try {
        DocumentSnapshot doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists) {
          return UserProfile.fromFirestore(doc);
        }
      } catch (e) {
        debugPrint("Firestore failed: $e");
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('mock_user');
    if (userStr != null) {
      final data = jsonDecode(userStr);
      return UserProfile(
        uid: data['uid'],
        email: data['email'],
        createdAt: DateTime.parse(data['createdAt']),
        questionnaireData: data['questionnaireData'],
      );
    }
    return null;
  }

  Future<void> updateQuestionnaireData(String uid, Map<String, dynamic> data) async {
    if (_isFirebaseUsable) {
      try {
        await _firestore!.collection('users').doc(uid).update({
          'questionnaireData': data,
        });
        return;
      } catch (e) {
        debugPrint("Firestore update failed: $e");
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('mock_user');
    if (userStr != null) {
      final userData = jsonDecode(userStr);
      userData['questionnaireData'] = data;
      await prefs.setString('mock_user', jsonEncode(userData));
    }
  }
}
