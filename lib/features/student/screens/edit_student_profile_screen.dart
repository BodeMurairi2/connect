import 'package:connect/features/onboarding/components/skills_selector.dart';
import 'package:connect/features/startups/data/post_opportunity.dart';
import 'package:connect/repositories/student_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditStudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditStudentProfileScreen({super.key, required this.profile});

  @override
  State<EditStudentProfileScreen> createState() =>
      _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {
  late final TextEditingController _bioCtrl;
  late Set<String> _selectedSkills;
  late List<TextEditingController> _portfolioCtrls;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController(
        text: widget.profile['bio'] as String? ?? '');
    _selectedSkills = Set<String>.from(
        widget.profile['skills'] as List? ?? []);
    final links =
        List<String>.from(widget.profile['portfolioLinks'] as List? ?? []);
    _portfolioCtrls = links.isNotEmpty
        ? links.map((l) => TextEditingController(text: l)).toList()
        : [TextEditingController()];
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    for (final c in _portfolioCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isSaving = true);
    try {
      final portfolioLinks = _portfolioCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Merge editable fields into existing profile data and re-save
      await StudentRepository().saveStudentProfile(
        uid: uid,
        year: widget.profile['year'] as String? ?? '',
        major: widget.profile['major'] as String? ?? '',
        bio: _bioCtrl.text.trim(),
        specialization: widget.profile['specialization'] as String? ?? '',
        skills: _selectedSkills.toList(),
        completeDegree: widget.profile['complete_degree'] as bool? ?? false,
        completedDate: widget.profile['completed_date'] != null
            ? (widget.profile['completed_date'] as dynamic).toDate()
            : DateTime.now(),
        portfolioLinks: portfolioLinks,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Edit Profile',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bio ──
            const Text('Bio',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell startups about yourself…',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Skills ──
            SkillsSelector(
              skills: opportunitySkills,
              initialSelected: _selectedSkills,
              onChanged: (selected) =>
                  setState(() => _selectedSkills = selected),
            ),
            const SizedBox(height: 24),

            // ── Portfolio links ──
            const Text('Portfolio / Project Links',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ..._portfolioCtrls.asMap().entries.map((entry) {
              final index = entry.key;
              final ctrl  = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        decoration: InputDecoration(
                          hintText: 'github.com/yourname',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0)),
                          ),
                          prefixIcon: const Icon(Icons.link,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    if (_portfolioCtrls.length > 1) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          _portfolioCtrls[index].dispose();
                          _portfolioCtrls.removeAt(index);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove,
                              color: Colors.red, size: 18),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() =>
                  _portfolioCtrls.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add another link'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
