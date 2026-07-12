import 'dart:async';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/bookmark_repository.dart';
import 'package:connect/repositories/opportunity_repository.dart';
import 'package:connect/repositories/student_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/student/components/feed_headers.dart';
import 'package:connect/features/student/components/feed_stats_row.dart';
import 'package:connect/features/student/components/opportunity_card.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const FeedScreen({super.key, this.onSeeAll});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<FeedOpportunity> _opportunities = [];
  List<Map<String, dynamic>> _rawOpportunities = [];
  Set<String> _studentSkills = {};
  Set<String> _appliedIds = {};
  Set<String> _bookmarkedIds = {};
  StreamSubscription<User?>? _authSub;
  StreamSubscription<Set<String>>? _appliedSub;
  StreamSubscription<Set<String>>? _bookmarkSub;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        _appliedSub?.cancel();
        _bookmarkSub?.cancel();
        _appliedSub = ApplicationRepository()
            .watchAppliedOpportunityIds(user.uid)
            .listen((ids) {
              if (mounted) setState(() => _appliedIds = ids);
            });
        _bookmarkSub = BookmarkRepository().watchBookmarkedIds(user.uid).listen(
          (ids) {
            if (mounted) setState(() => _bookmarkedIds = ids);
          },
        );
        _loadOpportunities(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _appliedSub?.cancel();
    _bookmarkSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOpportunities(String uid) async {
    // Load student skills and opportunities in parallel
    final results = await Future.wait([
      StudentRepository().getStudentProfile(uid),
      OpportunityRepository().getOpportunities(),
    ]);

    final profile = results[0] as Map<String, dynamic>?;
    final data = results[1] as List<Map<String, dynamic>>;
    final skills = profile != null
        ? Set<String>.from(profile['skills'] ?? [])
        : <String>{};

    if (mounted) {
      setState(() {
        _studentSkills = skills;
        _rawOpportunities = data;
        _opportunities = data
            .map((m) => mapToFeedOpportunity(m, studentSkills: skills))
            .toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark(String opportunityId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final repo = BookmarkRepository();
    if (_bookmarkedIds.contains(opportunityId)) {
      await repo.removeBookmark(uid, opportunityId);
    } else {
      final raw = _rawOpportunities.firstWhere(
        (r) => r['id'] == opportunityId,
        orElse: () => {},
      );
      if (raw.isNotEmpty) await repo.addBookmark(uid, raw);
    }
  }

  List<({FeedOpportunity opportunity, Map<String, dynamic> raw})> _filterBy(
    List<FeedOpportunity> list,
  ) {
    final result =
        <({FeedOpportunity opportunity, Map<String, dynamic> raw})>[];
    for (var i = 0; i < _opportunities.length; i++) {
      final o = _opportunities[i];
      if (!list.contains(o)) continue;
      if (_selectedCategory == 'All' || o.domain == _selectedCategory) {
        result.add((opportunity: o, raw: _rawOpportunities[i]));
      }
    }
    return result;
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _cardSliver(
    List<({FeedOpportunity opportunity, Map<String, dynamic> raw})> items,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return OpportunityCard(
            opportunity: item.opportunity,
            featured: index == 0,
            isApplied: _appliedIds.contains(item.opportunity.opportunityId),
            isBookmarked: _bookmarkedIds.contains(
              item.opportunity.opportunityId,
            ),
            onBookmark: () => _toggleBookmark(item.opportunity.opportunityId),
          );
        }, childCount: items.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommended = _opportunities
        .where((o) => o.skillsMatch >= 50)
        .toList();
    final others = _opportunities.where((o) => o.skillsMatch < 50).toList();

    final filteredRecommended = _filterBy(recommended);
    final filteredOthers = _filterBy(others);
    final hasRecommended =
        _studentSkills.isNotEmpty && filteredRecommended.isNotEmpty;

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
          FeedStatsRow(
            openCount: _opportunities.length,
            appliedCount: _appliedIds.length,
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else ...[
            if (hasRecommended) ...[
              SliverToBoxAdapter(
                child: _sectionHeader(
                  'Recommended for You ⚡',
                  trailing: GestureDetector(
                    onTap: widget.onSeeAll,
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              _cardSliver(filteredRecommended),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _sectionHeader(
                  filteredOthers.isEmpty
                      ? 'All Opportunities'
                      : 'More Opportunities',
                ),
              ),
            ] else
              SliverToBoxAdapter(
                child: _sectionHeader(
                  'All Opportunities',
                  trailing: GestureDetector(
                    onTap: widget.onSeeAll,
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            _cardSliver(
              hasRecommended ? filteredOthers : _filterBy(_opportunities),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
