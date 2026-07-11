import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connect/features/onboarding/components/onboarding_header.dart';
import 'package:connect/features/startups/components/startup_logo_upload.dart';
import 'package:connect/features/startups/components/domain_selector.dart';
import 'package:connect/repositories/startup_repository.dart';

class StartupOnboardingScreen extends StatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  State<StartupOnboardingScreen> createState() =>
      _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends State<StartupOnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedDomain;
  File? _logo;
  File? _businessCertificate;
  File? _aluAffiliation;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _teamSizeController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _founderNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  static const _domains = [
    'Fintech',
    'Edtech',
    'Health',
    'Agritech',
    'E-commerce',
    'Logistics',
  ];

  static final _fieldDecoration = InputDecoration(
    filled: true,
    fillColor: Color(0xFFF0F4FF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _teamSizeController.dispose();
    _websiteController.dispose();
    _founderNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String docType) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        final file = File(result.files.single.path!);
        if (docType == 'business') {
          _businessCertificate = file;
        } else {
          _aluAffiliation = file;
        }
      });
    }
  }

  Widget _documentUploadButton(String label, File? file, String docType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDocument(docType),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file != null
                        ? file.path.split('/').last
                        : 'Tap to upload (PDF or image)',
                    style: TextStyle(
                      color: file != null ? Colors.black87 : Colors.grey,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingHeader(currentStep: 1, totalSteps: 2),
                  const SizedBox(height: 24),
                  const Text(
                    "Register Startup",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tell us about your venture",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: StartupLogoUpload(
                      onImageSelected: (file) => setState(() => _logo = file),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Startup Name", style: _labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _fieldDecoration.copyWith(
                      hintText: "e.g. AnzaConnect",
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Startup name is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  const Text("Founder Name", style: _labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _founderNameController,
                    decoration: _fieldDecoration.copyWith(
                      hintText: "Your full name",
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Founder name is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  const Text("Domain", style: _labelStyle),
                  const SizedBox(height: 8),
                  DomainSelector(
                    domains: _domains,
                    onChanged: (value) =>
                        setState(() => _selectedDomain = value),
                  ),
                  const SizedBox(height: 16),

                  const Text("Description", style: _labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: _fieldDecoration.copyWith(
                      hintText:
                          "What does your startup do and what problem does it solve?",
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Description is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Team Size", style: _labelStyle),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _teamSizeController,
                              keyboardType: TextInputType.number,
                              decoration: _fieldDecoration.copyWith(
                                hintText: "e.g. 5",
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? "Required"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Location", style: _labelStyle),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _locationController,
                              decoration: _fieldDecoration.copyWith(
                                hintText: "e.g. Kigali",
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? "Required"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text("Website", style: _labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _websiteController,
                    decoration: _fieldDecoration.copyWith(hintText: "https://"),
                  ),
                  const SizedBox(height: 24),

                  _documentUploadButton(
                    "Business Registration Certificate",
                    _businessCertificate,
                    'business',
                  ),
                  const SizedBox(height: 16),

                  _documentUploadButton(
                    "ALU Affiliation Document",
                    _aluAffiliation,
                    'alu',
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verification Required",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Your startup will be reviewed by an ALU admin before going live on the platform.",
                          style: TextStyle(
                            color: Color(0xFFBF360C),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              if (_selectedDomain == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a domain'),
                                  ),
                                );
                                return;
                              }
                              if (_businessCertificate == null ||
                                  _aluAffiliation == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please upload both verification documents',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() => _isLoading = true);
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                final repo = StartupRepository();

                                String logoUrl = '';
                                if (_logo != null) {
                                  logoUrl = await repo.uploadDocument(
                                    uid,
                                    _logo!,
                                    'logo',
                                  );
                                }

                                final businessCertUrl = await repo
                                    .uploadDocument(
                                      uid,
                                      _businessCertificate!,
                                      'business_certificate',
                                    );
                                final aluAffiliationUrl = await repo
                                    .uploadDocument(
                                      uid,
                                      _aluAffiliation!,
                                      'alu_affiliation',
                                    );

                                await repo.saveStartupProfile(
                                  uid: uid,
                                  name: _nameController.text.trim(),
                                  field: _selectedDomain!,
                                  description: _descriptionController.text
                                      .trim(),
                                  founderName: _founderNameController.text
                                      .trim(),
                                  teamSize:
                                      int.tryParse(
                                        _teamSizeController.text.trim(),
                                      ) ??
                                      0,
                                  location: _locationController.text.trim(),
                                  website: _websiteController.text.trim(),
                                  businessCertificateUrl: businessCertUrl,
                                  aluAffiliationUrl: aluAffiliationUrl,
                                  logoUrl: logoUrl,
                                );

                                if (context.mounted) context.go('/startup');
                              } catch (error) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                                setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
