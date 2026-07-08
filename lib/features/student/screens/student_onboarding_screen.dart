import 'package:flutter/material.dart';
import 'package:connect/features/onboarding/components/onboarding_header.dart';
import 'package:connect/features/onboarding/components/academic_info_fields.dart';
import 'package:connect/features/onboarding/components/portfolio_links.dart';
import 'package:connect/features/onboarding/components/profile_picture_upload.dart';
import 'package:connect/features/onboarding/components/skills_selector.dart';

class StudentOnboardingScreen extends StatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  State<StudentOnboardingScreen> createState() =>
      _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends State<StudentOnboardingScreen> {
  String? _selectedYear;
  String? _selectedMajor;
  Set<String> _selectedSkills = {};
  List<String> _portfolioLinks = [];
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const skills = [
      'Flutter',
      'Firebase',
      'UI/UX',
      'Python',
      'React',
      'JavaScript',
      'Marketing',
      'Data Analysis',
      'Problem Solving',
      'Excel',
      'Words',
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingHeader(currentStep: 2, totalSteps: 3, onSkip: () {}),
                SizedBox(height: 24),
                Text(
                  "Build your profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Help startups discover your talent",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),
                Center(child: ProfilePictureUpload(onImageSelected: (file) {})),
                SizedBox(height: 24),
                AcademicInfoFields(
                  selectedMajor: _selectedMajor,
                  selectedYear: _selectedYear,
                  onYearChanged: (value) =>
                      setState(() => _selectedYear = value),
                  onMajorChanged: (value) =>
                      setState(() => _selectedMajor = value),
                ),
                SizedBox(height: 16),
                Text(
                  "Your Bio",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Tell startups about yourself...",
                    filled: true,
                    fillColor: Color(0xFFF0F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SkillsSelector(
                  skills: skills,
                  onChanged: (selected) =>
                      setState(() => _selectedSkills = selected),
                ),
                SizedBox(height: 16),
                PortfolioLinks(
                  onChanged: (links) => setState(() => _portfolioLinks = links),
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
                      "Complete Profile",
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
