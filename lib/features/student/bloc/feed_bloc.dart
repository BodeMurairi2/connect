import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/bookmark_repository.dart';
import 'package:connect/repositories/opportunity_repository.dart';
import 'package:connect/repositories/student_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  StreamSubscription<Set<String>>? _appliedSub;
  StreamSubscription<Set<String>>? _bookmarkSub;

  FeedBloc() : super(FeedInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<AppliedIdsUpdated>(_onAppliedIdsUpdated);
    on<BookmarkedIdsUpdated>(_onBookmarkedIdsUpdated);
    on<FeedCategoryChanged>(_onCategoryChanged);
    on<ToggleBookmark>(_onToggleBookmark);
  }

  @override
  Future<void> close() {
    _appliedSub?.cancel();
    _bookmarkSub?.cancel();
    return super.close();
  }

  Future<void> _onLoadFeed(
    LoadFeed event,
    Emitter<FeedState> emit,
  ) async {
    emit(FeedLoading());
    try {
      final results = await Future.wait([
        StudentRepository().getStudentProfile(event.uid),
        OpportunityRepository().getOpportunities(),
        FirebaseFirestore.instance.collection('Users').doc(event.uid).get(),
      ]);
      final profile = results[0] as Map<String, dynamic>?;
      final data = results[1] as List<Map<String, dynamic>>;
      final userDoc = results[2] as DocumentSnapshot<Map<String, dynamic>>;
      final skills = profile != null
          ? Set<String>.from(profile['skills'] ?? [])
          : <String>{};

      final userData = userDoc.data();
      final firstName = userData?['firstName'] as String? ?? '';
      final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

      final opportunities = data
          .map((m) => mapToFeedOpportunity(m, studentSkills: skills))
          .toList();

      _appliedSub?.cancel();
      _bookmarkSub?.cancel();
      _appliedSub = ApplicationRepository()
          .watchAppliedOpportunityIds(event.uid)
          .listen((ids) => add(AppliedIdsUpdated(ids)));
      _bookmarkSub = BookmarkRepository()
          .watchBookmarkedIds(event.uid)
          .listen((ids) => add(BookmarkedIdsUpdated(ids)));

      emit(FeedLoaded(
        opportunities: opportunities,
        rawOpportunities: data,
        studentSkills: skills,
        appliedIds: const {},
        bookmarkedIds: const {},
        studentName: firstName,
        studentPhotoUrl: photoUrl,
      ));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  void _onAppliedIdsUpdated(
    AppliedIdsUpdated event,
    Emitter<FeedState> emit,
  ) {
    if (state is FeedLoaded) {
      emit((state as FeedLoaded).copyWith(appliedIds: event.ids));
    }
  }

  void _onBookmarkedIdsUpdated(
    BookmarkedIdsUpdated event,
    Emitter<FeedState> emit,
  ) {
    if (state is FeedLoaded) {
      emit((state as FeedLoaded).copyWith(bookmarkedIds: event.ids));
    }
  }

  void _onCategoryChanged(
    FeedCategoryChanged event,
    Emitter<FeedState> emit,
  ) {
    if (state is FeedLoaded) {
      emit((state as FeedLoaded).copyWith(selectedCategory: event.category));
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoaded) return;
    final current = state as FeedLoaded;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final repo = BookmarkRepository();
    if (current.bookmarkedIds.contains(event.opportunityId)) {
      await repo.removeBookmark(uid, event.opportunityId);
    } else {
      final raw = current.rawOpportunities.firstWhere(
        (r) => r['id'] == event.opportunityId,
        orElse: () => {},
      );
      if (raw.isNotEmpty) await repo.addBookmark(uid, raw);
    }
  }
}
