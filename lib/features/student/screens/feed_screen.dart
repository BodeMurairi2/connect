import 'dart:async';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/opportunity_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/student/components/feed_headers.dart';
import 'package:connect/features/student/components/feed_stats_row.dart';
import 'package:connect/features/student/components/opportunity_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedCategory = 'All';
  Future<List<Map<String, dynamic>>> _opportunitiesFuture = Future.value([]);
  Stream<Set<String>> _appliedIdsStream = const Stream.empty();
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _opportunitiesFuture = OpportunityRepository().getOpportunities();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        setState(() {
          _appliedIdsStream = ApplicationRepository()
              .watchAppliedOpportunityIds(user.uid);
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  FeedOpportunity _mapToOpportunity(Map<String, dynamic> map) {
    final name = map['startupName'] as String? ?? '';
    return FeedOpportunity(
      opportunityId: map['id'] as String? ?? '',
      startupUid: map['startupUid'] as String? ?? '',
      startupName: name,
      role: map['title'] as String? ?? '',
      domain: map['roleType'] as String? ?? '',
      compensation: map['compensation'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      location: map['locationType'] as String? ?? '',
      avatarColor:
          Colors.primaries[name.hashCode.abs() % Colors.primaries.length],
      isVerified: false,
      skillsMatch: 0,
      postedAt: 'recently',
      description: map['description'] as String? ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      matchedSkills: [],
      responsibilities: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: CustomScrollView(
        slivers: [
          const FeedHeaderSliver(),
          FeedSearchSliver(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) =>
                setState(() => _selectedCategory = category),
          ),
          const FeedStatsRow(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<Set<String>>(
            stream: _appliedIdsStream,
            builder: (context, appliedSnapshot) {
              final appliedIds = appliedSnapshot.data ?? {};
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _opportunitiesFuture,
                builder: (context, connexion) {
                  if (connexion.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (connexion.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('Error: ${connexion.error}')),
                    );
                  }
                  final opportunities = (connexion.data ?? [])
                      .map(_mapToOpportunity)
                      .where(
                        (opportunity) =>
                            _selectedCategory == 'All' ||
                            opportunity.domain == _selectedCategory,
                      )
                      .toList();
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => OpportunityCard(
                          opportunity: opportunities[index],
                          featured: index == 0,
                          isApplied: appliedIds.contains(
                            opportunities[index].opportunityId,
                          ),
                        ),
                        childCount: opportunities.length,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
