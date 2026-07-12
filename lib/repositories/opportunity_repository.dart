import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<void> postOpportunity({
    required String startupUid,
    required String startupName,
    required String title,
    required String roleType,
    required String description,
    required List<String> skills,
    required String duration,
    required String compensation,
    required String currency,
    required String salary,
    required String locationType,
    required String address,
  }) async {
    await _firestore.collection('Opportunities').add({
      'startupUid': startupUid,
      'startupName': startupName,
      'title': title,
      'roleType': roleType,
      'description': description,
      'skills': skills,
      'duration': duration,
      'compensation': compensation,
      'currency': currency,
      'salary': salary,
      'locationType': locationType,
      'address': address,
      'applicantsCount': 0,
      'isOpen': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOpportunity(
    String id, {
    required String title,
    required String roleType,
    required String description,
    required List<String> skills,
    required String duration,
    required String compensation,
    required String currency,
    required String salary,
    required String locationType,
    required String address,
    required bool isOpen,
  }) async {
    await _firestore.collection('Opportunities').doc(id).update({
      'title': title,
      'roleType': roleType,
      'description': description,
      'skills': skills,
      'duration': duration,
      'compensation': compensation,
      'currency': currency,
      'salary': salary,
      'locationType': locationType,
      'address': address,
      'isOpen': isOpen,
    });
  }

  Future<List<Map<String, dynamic>>> getOpportunities() async {
    final docOpportunities = await _firestore
        .collection('Opportunities')
        .where('isOpen', isEqualTo: true)
        .get();

    final opportunities = docOpportunities.docs
        .map((document) => {'id': document.id, ...document.data()})
        .toList();
    opportunities.sort((before, after) {
      final beforeTime = before['createdAt'];
      final afterTime = after['createdAt'];
      if (beforeTime == null || afterTime == null) return 0;
      return afterTime.compareTo(beforeTime);
    });
    return opportunities;
  }
}
