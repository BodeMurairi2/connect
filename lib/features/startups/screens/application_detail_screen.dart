import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connect/features/startups/bloc/startup_bloc.dart';
import 'package:connect/features/startups/bloc/startup_event.dart';
import 'package:connect/repositories/student_repository.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  Map<String, dynamic>? _studentProfile;
  bool _loadingProfile = true;
  late Map<String, dynamic> _app;

  @override
  void initState() {
    super.initState();
    _app = Map<String, dynamic>.from(widget.application);
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final uid = _app['studentUid'] as String? ?? '';
    if (uid.isEmpty) {
      setState(() => _loadingProfile = false);
      return;
    }
    final profile = await StudentRepository().getStudentProfile(uid);
    if (mounted) setState(() { _studentProfile = profile; _loadingProfile = false; });
  }

  Color _avatarColor(String name) {
    final colors = [
      Colors.orange, Colors.purple, Colors.blue,
      Colors.green, Colors.red, Colors.teal,
    ];
    if (name.isEmpty) return Colors.grey;
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  void _updateStatus(String status) {
    context.read<StartupBloc>().add(
          UpdateApplicantStatus(app: _app, newStatus: status),
        );
    setState(() => _app = {..._app, 'status': status});
  }

  Widget _statusBadge(String status) {
    final colors = {
      'Pending':   (bg: const Color(0xFFFFF8E1), text: const Color(0xFFE65100)),
      'Reviewing': (bg: const Color(0xFFE3F2FD), text: Colors.blue),
      'Accepted':  (bg: const Color(0xFFE8F5E9), text: Colors.green),
      'Declined':  (bg: const Color(0xFFFFEBEE), text: Colors.red),
    };
    final sc = colors[status] ??
        (bg: Colors.grey.shade100, text: Colors.grey as Color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: sc.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: sc.text, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );

  Widget _docButton(String label, String? url, IconData icon, Color color) {
    final hasUrl = url != null && url.isNotEmpty;
    return OutlinedButton.icon(
      onPressed: hasUrl ? () => _openUrl(url) : null,
      icon: Icon(icon, size: 16,
          color: hasUrl ? color : Colors.grey),
      label: Text(label,
          style: TextStyle(
              color: hasUrl ? color : Colors.grey, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: hasUrl ? color : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  List<Widget> _actionButtons() {
    final status = _app['status'] as String? ?? 'Pending';
    switch (status) {
      case 'Pending':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('Declined'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus('Reviewing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Move to Review'),
            ),
          ),
        ];
      case 'Reviewing':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('Declined'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus('Accepted'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Accept'),
            ),
          ),
        ];
      case 'Accepted':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('Declined'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Revoke Acceptance'),
            ),
          ),
        ];
      case 'Declined':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatus('Reviewing'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Reconsider'),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _app['studentName'] as String? ?? 'Unknown';
    final email = _app['studentEmail'] as String? ?? '';
    final opportunityTitle = _app['opportunityTitle'] as String? ?? '';
    final coverLetter = _app['coverLetter'] as String? ?? '';
    final cvUrl = _app['cvUrl'] as String?;
    final coverLetterFileUrl = _app['coverLetterFileUrl'] as String?;
    final portfolioLinks = List<String>.from(_app['portfolioLinks'] ?? []);
    final status = _app['status'] as String? ?? 'Pending';

    final bio = _studentProfile?['bio'] as String? ?? '';
    final skills = List<String>.from(_studentProfile?['skills'] ?? []);
    final major = _studentProfile?['major'] as String? ?? '';
    final year = _studentProfile?['year'] as String? ?? '';
    final specialization = _studentProfile?['specialization'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Application',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [_statusBadge(status), const SizedBox(width: 16)],
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Student header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _avatarColor(name),
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            if (email.isNotEmpty)
                              Text(email,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey)),
                            if (opportunityTitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Applied for: $opportunityTitle',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.blue)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Academic info + bio
                if (bio.isNotEmpty || major.isNotEmpty || year.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Profile'),
                        if (major.isNotEmpty || year.isNotEmpty || specialization.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (year.isNotEmpty)
                                _infoChip(Icons.school_outlined, year),
                              if (major.isNotEmpty)
                                _infoChip(Icons.book_outlined, major),
                              if (specialization.isNotEmpty)
                                _infoChip(Icons.star_outline, specialization),
                            ],
                          ),
                        if (bio.isNotEmpty) ...[
                          if (major.isNotEmpty || year.isNotEmpty)
                            const SizedBox(height: 10),
                          Text(bio,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                if (bio.isNotEmpty || major.isNotEmpty || year.isNotEmpty)
                  const SizedBox(height: 12),

                // Skills
                if (skills.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Skills'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skills
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue
                                              .withValues(alpha: 0.25)),
                                    ),
                                    child: Text(s,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                if (skills.isNotEmpty) const SizedBox(height: 12),

                // Cover letter
                if (coverLetter.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Cover Letter'),
                        Text(coverLetter,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.6)),
                      ],
                    ),
                  ),
                if (coverLetter.isNotEmpty) const SizedBox(height: 12),

                // Documents
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Documents'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _docButton(
                              'Open CV',
                              cvUrl,
                              Icons.description_outlined,
                              Colors.blue),
                          _docButton(
                              'Cover Letter Doc',
                              coverLetterFileUrl,
                              Icons.article_outlined,
                              Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),

                // Portfolio links
                if (portfolioLinks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Portfolio Links'),
                        ...portfolioLinks.map((link) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () => _openUrl(link),
                                child: Row(
                                  children: [
                                    const Icon(Icons.link,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        link,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: _actionButtons()),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.grey.shade600),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      );
}
