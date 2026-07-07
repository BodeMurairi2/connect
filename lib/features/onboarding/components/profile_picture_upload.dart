import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePictureUpload extends StatefulWidget {
  final Function(File image) onImageSelected;
  const ProfilePictureUpload({super.key, required this.onImageSelected});

  @override
  State<ProfilePictureUpload> createState() => _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<ProfilePictureUpload> {
  File? _image;

  Future<void> _pickImage() async {
    // TODO: this function wire up image _picker
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _image != null
                ? ClipOval(child: Image.file(_image!, fit: BoxFit.cover))
                : Icon(Icons.person, size: 40, color: Colors.grey[400]),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
