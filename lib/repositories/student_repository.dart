import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveStudentProfile({
    required String uid,
    required String year,
    required String major,
    required String bio,
    required String specialization,
    required List<String> skills,
    required bool completeDegree,
    required DateTime completedDate,
    required List<String> portfolioLinks,
  }) async {
    await _firestore.collection('Students').doc(uid).set({
      'uid': uid,
      'year': year,
      'major': major,
      'bio': bio,
      'specialization': specialization,
      'skills': skills,
      'complete_degree': completeDegree,
      'completed_date': Timestamp.fromDate(completedDate),
      'portfolioLinks': portfolioLinks,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    final doc = await _firestore.collection('Students').doc(uid).get();
    return doc.exists;
  }

  Future<Map<String, dynamic>?> getStudentProfile(String uid) async {
    final doc = await _firestore.collection('Students').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
