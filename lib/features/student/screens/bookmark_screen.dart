import 'dart:async';
import 'package:connect/features/student/components/opportunity_card.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/bookmark_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  Stream<List<Map<String, dynamic>>> _bookmarksStream = const Stream.empty();
  Set<String> _appliedIds = {};
  StreamSubscription<User?>? _authSub;
  StreamSubscription<Set<String>>? _appliedSub;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        _uid = user.uid;
        _appliedSub?.cancel();
        _appliedSub = ApplicationRepository()
            .watchAppliedOpportunityIds(user.uid)
            .listen((ids) { if (mounted) setState(() => _appliedIds = ids); });
        setState(() {
          _bookmarksStream =
              BookmarkRepository().watchBookmarks(user.uid);
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _appliedSub?.cancel();
    super.dispose();
  }

  Future<void> _removeBookmark(String opportunityId) async {
    if (_uid == null) return;
    await BookmarkRepository().removeBookmark(_uid!, opportunityId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Saved',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _bookmarksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookmarks = snapshot.data ?? [];
          if (bookmarks.isEmpty) {
            return const Center(
              child: Text(
                'Tap the bookmark icon on any\nopportunity to save it here',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final map = bookmarks[index];
              final opportunity = mapToFeedOpportunity(map);
              return OpportunityCard(
                opportunity: opportunity,
                isApplied: _appliedIds.contains(opportunity.opportunityId),
                isBookmarked: true,
                onBookmark: () => _removeBookmark(opportunity.opportunityId),
              );
            },
          );
        },
      ),
    );
  }
}
