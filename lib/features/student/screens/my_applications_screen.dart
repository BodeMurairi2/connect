import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/opportunity_repository.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  Stream<List<Map<String, dynamic>>> _applicationsStream = const Stream.empty();
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        setState(() {
          _applicationsStream = ApplicationRepository()
              .watchApplicationsForStudent(user.uid);
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _openOpportunity(String opportunityId) async {
    final map = await OpportunityRepository().getOpportunityById(opportunityId);
    if (map == null || !mounted) return;
    final name = map['startupName'] as String? ?? '';
    final opportunity = FeedOpportunity(
      opportunityId: map['id'] as String? ?? '',
      startupUid: map['startupUid'] as String? ?? '',
      startupName: name,
      role: map['title'] as String? ?? '',
      domain: map['roleType'] as String? ?? '',
      compensation: map['compensation'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      location: map['locationType'] as String? ?? '',
      description: map['description'] as String? ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      avatarColor: Colors.primaries[name.hashCode.abs() % Colors.primaries.length],
      isVerified: false,
      skillsMatch: 0,
      postedAt: 'recently',
      matchedSkills: [],
      responsibilities: [],
    );
    if (mounted) context.push('/student/opportunity', extra: opportunity);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Review':
        return Colors.blue;
      case 'Interview':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        title: const Text(
          'My Applications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return const Center(
              child: Text(
                'No applications yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final status = app['status'] as String? ?? 'Pending';
              return GestureDetector(
                onTap: () => _openOpportunity(app['opportunityId'] as String? ?? ''),
                child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app['opportunityTitle'] as String? ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app['startupName'] as String? ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }
}
