import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class StartupLogoUpload extends StatefulWidget {
  final Function(File image) onImageSelected;

  const StartupLogoUpload({super.key, required this.onImageSelected});

  @override
  State<StartupLogoUpload> createState() => _StartupLogoUploadState();
}

class _StartupLogoUploadState extends State<StartupLogoUpload> {
  File? _image;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() => _image = file);
      widget.onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFFF3EEFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  )
                : Icon(Icons.add_a_photo, color: Colors.purple, size: 32),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Upload Logo",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
