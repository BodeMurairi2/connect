import 'dart:io';
import 'package:connect/repositories/r2_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageRepository {
  Future<String> uploadDocument(PlatformFile file, String folder) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ext = file.name.split('.').last;
    final objectKey = '$folder/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

    if (file.bytes != null) {
      return R2StorageService().uploadBytes(
        bytes: file.bytes!,
        objectKey: objectKey,
        fileName: file.name,
      );
    } else if (file.path != null) {
      return R2StorageService().uploadFile(File(file.path!), objectKey);
    } else {
      throw Exception('Could not read file — no bytes or path available');
    }
  }
}
