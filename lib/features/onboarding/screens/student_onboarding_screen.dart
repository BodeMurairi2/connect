import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connect/features/onboarding/components/onboarding_header.dart';
import 'package:connect/features/onboarding/components/academic_info_fields.dart';
import 'package:connect/features/onboarding/components/portfolio_links.dart';
import 'package:connect/features/onboarding/components/profile_picture_upload.dart';
import 'package:connect/features/onboarding/components/skills_selector.dart';
import 'package:connect/repositories/student_repository.dart';

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
  final TextEditingController _specializationController = TextEditingController();
  bool _isLoading = false;
  bool _completeDegree = true;
  DateTime? _completedDate;

  static const _skills = [
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
    'Writing',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (_selectedYear == null || _selectedMajor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your academic year and major'),
        ),
      );
      return;
    }

    if (_completedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your graduation date')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final filteredLinks = _portfolioLinks
          .where((l) => l.trim().isNotEmpty)
          .toList();

      await StudentRepository().saveStudentProfile(
        uid: uid,
        year: _selectedYear!,
        major: _selectedMajor!,
        bio: _bioController.text.trim(),
        specialization: _specializationController.text.trim(),
        skills: _selectedSkills.toList(),
        completeDegree: _completeDegree,
        completedDate: _completedDate!,
        portfolioLinks: filteredLinks,
      );

      if (mounted) context.go('/student');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      if (mounted) setState(() => _isLoading = false);
    }
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
                OnboardingHeader(
                  currentStep: 2,
                  totalSteps: 3,
                  onSkip: () => context.go('/student'),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Build your profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E2D),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Help startups discover your talent",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Center(child: ProfilePictureUpload(onImageSelected: (file) {})),
                const SizedBox(height: 24),
                AcademicInfoFields(
                  selectedMajor: _selectedMajor,
                  selectedYear: _selectedYear,
                  onYearChanged: (value) =>
                      setState(() => _selectedYear = value),
                  onMajorChanged: (value) =>
                      setState(() => _selectedMajor = value),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Specialization",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _specializationController,
                  decoration: InputDecoration(
                    hintText: "e.g. Mobile Development, Data Science...",
                    filled: true,
                    fillColor: const Color(0xFFF0F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Your Bio",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Tell startups about yourself...",
                    filled: true,
                    fillColor: const Color(0xFFF0F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    'Have you already completed your degree at ALU?',
                  ),
                  value: _completeDegree,
                  onChanged: (value) => setState(() => _completeDegree = value),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Graduation Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099),
                    );
                    if (picked != null) {
                      setState(() => _completedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _completedDate == null
                              ? 'Select graduation date'
                              : '${_completedDate!.day}/${_completedDate!.month}/${_completedDate!.year}',
                          style: TextStyle(
                            color: _completedDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SkillsSelector(
                  skills: _skills,
                  onChanged: (selected) =>
                      setState(() => _selectedSkills = selected),
                ),
                const SizedBox(height: 16),
                PortfolioLinks(
                  onChanged: (links) => setState(() => _portfolioLinks = links),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                            "Complete Profile",
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
    );
  }
}
