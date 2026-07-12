import 'dart:async';
import 'package:connect/features/student/components/opportunity_card.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/bookmark_repository.dart';
import 'package:connect/repositories/opportunity_repository.dart';
import 'package:connect/repositories/student_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connect/features/student/data/feed_data.dart';

class SearchScreens extends StatefulWidget {
  const SearchScreens({super.key});

  @override
  State<SearchScreens> createState() => _SearchScreensState();
}

class _SearchScreensState extends State<SearchScreens> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'All';
  List<FeedOpportunity> _allOpportunities = [];
  List<Map<String, dynamic>> _rawOpportunities = [];
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
            .listen((ids) { if (mounted) setState(() => _appliedIds = ids); });
        _bookmarkSub = BookmarkRepository()
            .watchBookmarkedIds(user.uid)
            .listen((ids) { if (mounted) setState(() => _bookmarkedIds = ids); });
        _loadOpportunities(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _authSub?.cancel();
    _appliedSub?.cancel();
    _bookmarkSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOpportunities(String uid) async {
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
        _rawOpportunities = data;
        _allOpportunities = data
            .map((m) => mapToFeedOpportunity(m, studentSkills: skills))
            .toList();
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

  List<({FeedOpportunity opportunity})> get _results =>
      _allOpportunities.where((o) {
        final matchesQuery = _query.isEmpty ||
            o.role.toLowerCase().contains(_query.toLowerCase()) ||
            o.startupName.toLowerCase().contains(_query.toLowerCase());
        final matchesFilter =
            _selectedFilter == 'All' || o.domain == _selectedFilter;
        return matchesQuery && matchesFilter;
      }).map((o) => (opportunity: o)).toList();

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search roles, startups...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    onPressed: () => setState(() {
                      _query = '';
                      _searchController.clear();
                    }),
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'Engineering',
                  'Design',
                  'Marketing',
                  'Finance',
                  'Agriculture',
                  'Education',
                ]
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = filter),
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'No opportunities available'
                              : 'No results for "$_query"',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final o = results[index].opportunity;
                      return OpportunityCard(
                        opportunity: o,
                        isApplied: _appliedIds.contains(o.opportunityId),
                        isBookmarked: _bookmarkedIds.contains(o.opportunityId),
                        onBookmark: () => _toggleBookmark(o.opportunityId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
