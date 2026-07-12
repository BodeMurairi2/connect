import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _items(String studentUid) => _firestore
      .collection('Bookmarks')
      .doc(studentUid)
      .collection('items');

  Future<void> addBookmark(String studentUid, Map<String, dynamic> opportunityMap) async {
    final id = opportunityMap['id'] as String;
    await _items(studentUid).doc(id).set({
      ...opportunityMap,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String studentUid, String opportunityId) async {
    await _items(studentUid).doc(opportunityId).delete();
  }

  Stream<Set<String>> watchBookmarkedIds(String studentUid) {
    return _items(studentUid).snapshots().map(
      (snap) => snap.docs.map((d) => d.id).toSet(),
    );
  }

  Stream<List<Map<String, dynamic>>> watchBookmarks(String studentUid) {
    return _items(studentUid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
            .toList());
  }
}
