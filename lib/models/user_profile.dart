import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? username;
  final DateTime createdAt;
  final Map<String, dynamic>? questionnaireData;

  UserProfile({
    required this.uid,
    required this.email,
    this.username,
    required this.createdAt,
    this.questionnaireData,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      questionnaireData: data['questionnaireData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'createdAt': Timestamp.fromDate(createdAt),
      'questionnaireData': questionnaireData,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? username,
    DateTime? createdAt,
    Map<String, dynamic>? questionnaireData,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      questionnaireData: questionnaireData ?? this.questionnaireData,
    );
  }
}
