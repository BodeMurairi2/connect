import 'package:connect/features/student/components/document_upload_button.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/notification_repository.dart';
import 'package:connect/repositories/storage_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplyScreen extends StatefulWidget {
  final FeedOpportunity opportunity;
  const ApplyScreen({super.key, required this.opportunity});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final TextEditingController _applicationController = TextEditingController();
  final List<TextEditingController> _portfolioControllers = [
    TextEditingController(),
  ];
  bool _isLoading = false;
  PlatformFile? _cvFile;
  PlatformFile? _coverLetterFile;

  Future<void> _pickDocument(bool isCv) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    if (result != null && mounted) {
      setState(() {
        if (isCv) {
          _cvFile = result.files.single;
        } else {
          _coverLetterFile = result.files.single;
        }
      });
    }
  }

  @override
  void dispose() {
    _applicationController.dispose();
    for (final controller in _portfolioControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.opportunity.deadline != null &&
        DateTime.now().isAfter(widget.opportunity.deadline!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The application deadline for this opportunity has passed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final coverLetterText = _applicationController.text.trim();
    if (coverLetterText.isEmpty && _coverLetterFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a cover letter or upload a cover letter document'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final alreadyApplied = await ApplicationRepository().hasApplied(
        user.uid,
        widget.opportunity.opportunityId,
      );
      if (alreadyApplied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already applied to this opportunity'),
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      final storage = StorageRepository();
      final cvUrl = _cvFile != null
          ? await storage.uploadDocument(_cvFile!, 'cvs')
          : null;
      final coverLetterFileUrl = _coverLetterFile != null
          ? await storage.uploadDocument(_coverLetterFile!, 'cover_letters')
          : null;

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      final data = userDoc.data();
      final studentName = data != null
          ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim()
          : user.displayName ?? '';

      final portfolioLinks = _portfolioControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final resolvedName =
          studentName.isEmpty ? (user.email ?? 'Unknown') : studentName;
      await ApplicationRepository().submitApplication(
        studentUid: user.uid,
        studentName: resolvedName,
        studentEmail: user.email ?? '',
        opportunityId: widget.opportunity.opportunityId,
        opportunityTitle: widget.opportunity.role,
        startupUid: widget.opportunity.startupUid,
        startupName: widget.opportunity.startupName,
        coverLetter: coverLetterText,
        portfolioLinks: portfolioLinks,
        cvUrl: cvUrl,
        coverLetterFileUrl: coverLetterFileUrl,
      );

      // Fire-and-forget confirmation email — non-blocking
      NotificationRepository().sendApplicationConfirmation(
        studentEmail: user.email ?? '',
        studentName: resolvedName,
        opportunityTitle: widget.opportunity.role,
        startupName: widget.opportunity.startupName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.withValues(alpha: 0.4),
        title: Text(
          'Apply',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.opportunity.avatarColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.opportunity.startupName[0],
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.opportunity.role,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.opportunity.startupName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.opportunity.matchedSkills.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Matching Skills:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.opportunity.matchedSkills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Cover Letter ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '(optional if uploading a document below)',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _applicationController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Tell them why you are the right fit",
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload CV',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DocumentUploadButton(
              label: 'Upload your CV',
              file: _cvFile,
              onPick: () => _pickDocument(true),
              onRemove: () => setState(() => _cvFile = null),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Cover Letter Document — Optional if written above',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DocumentUploadButton(
              label: 'Upload cover letter document',
              file: _coverLetterFile,
              onPick: () => _pickDocument(false),
              onRemove: () => setState(() => _coverLetterFile = null),
            ),
            const SizedBox(height: 16),
            const Text(
              'Portfolio / Project Links',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ..._portfolioControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'github.com/yourname',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.link,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (_portfolioControllers.length > 1) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          _portfolioControllers[index].dispose();
                          _portfolioControllers.removeAt(index);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(
                () => _portfolioControllers.add(TextEditingController()),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add another link'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'You can only apply once per opportunity. Make your pitch count!',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
