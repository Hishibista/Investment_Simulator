import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic>? questionnaireData;

  UserProfile({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.questionnaireData,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      questionnaireData: data['questionnaireData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'questionnaireData': questionnaireData,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    Map<String, dynamic>? questionnaireData,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      questionnaireData: questionnaireData ?? this.questionnaireData,
    );
  }
}
