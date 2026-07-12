import 'dart:async';
import 'package:connect/features/student/components/opportunity_card.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/opportunity_repository.dart';
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
  Stream<Set<String>> _appliedIdsStream = const Stream.empty();
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
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
    _searchController.dispose();
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadOpportunities() async {
    final data = await OpportunityRepository().getOpportunities();
    if (mounted) {
      setState(() {
        _allOpportunities = data.map(_mapToOpportunity).toList();
      });
    }
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
      description: map['description'] as String? ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      avatarColor: Colors.primaries[name.hashCode.abs() % Colors.primaries.length],
      isVerified: false,
      skillsMatch: 0,
      postedAt: 'recently',
      matchedSkills: [],
      responsibilities: [],
    );
  }

  List<FeedOpportunity> get _results => _allOpportunities.where((o) {
    final matchesQuery =
        _query.isEmpty ||
        o.role.toLowerCase().contains(_query.toLowerCase()) ||
        o.startupName.toLowerCase().contains(_query.toLowerCase());
    final matchesFilter = _selectedFilter == 'All' || o.domain == _selectedFilter;
    return matchesQuery && matchesFilter;
  }).toList();

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                          'All',
                          'Engineering',
                          'Design',
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
                              onSelected: ((value) =>
                                  setState(() => _selectedFilter = filter)),
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
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No results for "$_query"',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<Set<String>>(
                    stream: _appliedIdsStream,
                    builder: (context, appliedSnapshot) {
                      final appliedIds = appliedSnapshot.data ?? {};
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) => OpportunityCard(
                          opportunity: _results[index],
                          isApplied: appliedIds.contains(_results[index].opportunityId),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
