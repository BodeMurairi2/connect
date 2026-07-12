import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> submitApplication({
    required String studentUid,
    required String studentName,
    required String studentEmail,
    required String opportunityId,
    required String opportunityTitle,
    required String startupUid,
    required String startupName,
    required String coverLetter,
    required List<String> portfolioLinks,
    String? cvUrl,
    String? coverLetterFileUrl,
  }) async {
    final batch = _firestore.batch();

    final appRef = _firestore.collection('Applications').doc();
    batch.set(appRef, {
      'studentUid': studentUid,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupUid': startupUid,
      'startupName': startupName,
      'coverLetter': coverLetter,
      'portfolioLinks': portfolioLinks,
      'cvUrl': cvUrl,
      'coverLetterFileUrl': coverLetterFileUrl,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (opportunityId.isNotEmpty) {
      final oppRef = _firestore.collection('Opportunities').doc(opportunityId);
      batch.update(oppRef, {'applicantsCount': FieldValue.increment(1)});
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getApplicationsForStartup(
    String startupUid,
  ) async {
    final snapshot = await _firestore
        .collection('Applications')
        .where('startupUid', isEqualTo: startupUid)
        .get();
    final docs = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    docs.sort((a, b) {
      final aTime = a['createdAt'];
      final bTime = b['createdAt'];
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    return docs;
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    await _firestore.collection('Applications').doc(applicationId).update({
      'status': status,
    });
  }

  Future<bool> hasApplied(String studentUid, String opportunityId) async {
    final snapshot = await _firestore
        .collection('Applications')
        .where('studentUid', isEqualTo: studentUid)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<Set<String>> watchAppliedOpportunityIds(String studentUid) {
    return _firestore
        .collection('Applications')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc['opportunityId'] as String)
            .toSet());
  }

  Stream<List<Map<String, dynamic>>> watchApplicationsForStudent(
    String studentUid,
  ) {
    return _firestore
        .collection('Applications')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          docs.sort((a, b) {
            final aTime = a['createdAt'];
            final bTime = b['createdAt'];
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return docs;
        });
  }
}
