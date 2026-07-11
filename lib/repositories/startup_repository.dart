import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/repositories/r2_storage_service.dart';

class StartupRepository {
  final _firestore = FirebaseFirestore.instance;
  final _r2 = R2StorageService();

  Future<void> saveStartupProfile({
    required String uid,
    required String name,
    required String field,
    required String description,
    required String businessCertificateUrl,
    required String aluAffiliationUrl,
    required String founderName,
    required int teamSize,
    required String location,
    required String website,
    required String logoUrl,
  }) async {
    await _firestore.collection('Startups').doc(uid).set({
      'name': name,
      'field': field,
      'description': description,
      'businessCertificateUrl': businessCertificateUrl,
      'aluAffiliationUrl': aluAffiliationUrl,
      'founderName': founderName,
      'teamSize': teamSize,
      'location': location,
      'website': website,
      'logoUrl': logoUrl,
      'isVerified': false,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    final doc = await _firestore.collection('Startups').doc(uid).get();
    return doc.exists;
  }

  Future<Map<String, dynamic>?> getStartupProfile(String uid) async {
    final doc = await _firestore.collection('Startups').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> getStartupOpportunities(String uid) async {
    final snapshot = await _firestore
        .collection('Opportunities')
        .where('startupUid', isEqualTo: uid)
        .get();
    final docs = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    docs.sort((a, b) {
      final aTime = a['createdAt'];
      final bTime = b['createdAt'];
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    return docs;
  }

  Future<String> uploadDocument(String uid, File file, String docType) async {
    final fileName = file.path.split('/').last;
    return await _r2.uploadFile(file, 'startups/$uid/$docType/$fileName');
  }
}
