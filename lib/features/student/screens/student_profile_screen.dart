import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/features/student/screens/edit_student_profile_screen.dart';
import 'package:connect/repositories/auth_repository.dart';
import 'package:connect/repositories/student_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Map<String, dynamic>? _studentDoc; // Students collection
  Map<String, dynamic>? _userDoc;    // Users collection
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final results = await Future.wait([
      StudentRepository().getStudentProfile(user.uid),
      _fetchUserDoc(user.uid),
    ]);
    if (mounted) {
      setState(() {
        _studentDoc = results[0];
        _userDoc    = results[1];
        _isLoading  = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchUserDoc(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();
    return doc.exists ? doc.data() : null;
  }

  bool get _isEmailUser {
    final providers = FirebaseAuth.instance.currentUser?.providerData
            .map((p) => p.providerId)
            .toList() ??
        [];
    return providers.contains('password');
  }

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    final first = _userDoc?['firstName'] as String? ?? '';
    final last  = _userDoc?['lastName']  as String? ?? '';
    final full  = '$first $last'.trim();
    return full.isNotEmpty
        ? full
        : (user?.displayName ?? user?.email ?? 'Student');
  }

  String get _initials {
    final parts = _displayName.trim().split(' ');
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last  = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Future<void> _changePassword() async {
    final newPwCtrl    = TextEditingController();
    final confirmCtrl  = TextEditingController();
    bool obscure = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPwCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'New password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDlg(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: obscure,
                decoration:
                    const InputDecoration(labelText: 'Confirm password'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final pw = newPwCtrl.text.trim();
                if (pw.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Password must be at least 6 characters')));
                  return;
                }
                if (pw != confirmCtrl.text.trim()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Passwords do not match')));
                  return;
                }
                try {
                  await FirebaseAuth.instance.currentUser!.updatePassword(pw);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password updated successfully'),
                          backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    newPwCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AuthService().signOut();
      if (mounted) context.go('/role-selection');
    }
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final user            = FirebaseAuth.instance.currentUser;
    final skills          = List<String>.from(_studentDoc?['skills'] ?? []);
    final portfolioLinks  = List<String>.from(_studentDoc?['portfolioLinks'] ?? []);
    final bio             = _studentDoc?['bio']             as String? ?? '';
    final major           = _studentDoc?['major']           as String? ?? '';
    final year            = _studentDoc?['year']            as String? ?? '';
    final specialization  = _studentDoc?['specialization']  as String? ?? '';
    final photoUrl        = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: _isLoading
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditStudentProfileScreen(
                            profile: _studentDoc ?? {}),
                      ),
                    );
                    _load();
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar + name ──
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue,
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(_initials,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(_displayName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Academic info ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Academic Info',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        _infoRow('Major', major),
                        _infoRow('Year', year),
                        _infoRow('Specialization', specialization),
                        if (bio.isNotEmpty) ...[
                          const Divider(height: 20),
                          const Text('Bio',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 8),
                          Text(bio,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Skills ──
                  if (skills.isNotEmpty) ...[
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Skills',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills
                                .map((s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.blue
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Text(s,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Portfolio ──
                  if (portfolioLinks.isNotEmpty) ...[
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Portfolio / Links',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 12),
                          ...portfolioLinks.map(
                            (link) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(children: [
                                const Icon(Icons.link,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(link,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Account actions ──
                  _card(
                    child: Column(
                      children: [
                        if (_isEmailUser) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.lock_outline,
                                color: Colors.blue),
                            title: const Text('Change Password',
                                style: TextStyle(fontSize: 14)),
                            trailing: const Icon(Icons.chevron_right,
                                color: Colors.grey),
                            onTap: _changePassword,
                          ),
                          const Divider(height: 1),
                        ],
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                              const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Sign Out',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.red)),
                          onTap: _signOut,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
