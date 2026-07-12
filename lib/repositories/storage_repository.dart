import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadDocument(PlatformFile file, String folder) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ext = file.name.split('.').last;
    final ref = _storage.ref('$folder/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext');
    final uploadTask = ref.putFile(File(file.path!));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
