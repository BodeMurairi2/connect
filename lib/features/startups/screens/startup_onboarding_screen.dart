import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connect/features/onboarding/components/onboarding_header.dart';
import 'package:connect/features/startups/components/startup_logo_upload.dart';
import 'package:connect/features/startups/components/domain_selector.dart';

class StartupOnboardingScreen extends StatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  State<StartupOnboardingScreen> createState() =>
      _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends State<StartupOnboardingScreen> {
  String? _selectedDomain;
  File? _logo;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _teamSizeController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingHeader(currentStep: 1, totalSteps: 2),
                SizedBox(height: 24),
                Text(
                  "Register Startup",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tell us about your venture",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),
                Center(
                  child: StartupLogoUpload(
                    onImageSelected: (file) => setState(() => _logo = file),
                  ),
                ),
                SizedBox(height: 24),
                Text("Startup Name", style: _labelStyle),
                SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _fieldDecoration.copyWith(
                    hintText: "e.g. AnzaConnect",
                  ),
                ),
                SizedBox(height: 16),
                const Text(
                  "Domain",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DomainSelector(
                  domains: _domains,
                  onChanged: (value) => setState(() => _selectedDomain = value),
                ),
                SizedBox(height: 16),
                Text("Description", style: _labelStyle),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _fieldDecoration.copyWith(
                    hintText: "What does your startup do?",
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Team Size", style: _labelStyle),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _teamSizeController,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration.copyWith(
                              hintText: "e.g. 5",
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Website", style: _labelStyle),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _websiteController,
                            decoration: _fieldDecoration.copyWith(
                              hintText: "https://",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFFFE082)),
                  ),
                  child: Column(
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
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
