import 'package:connect/features/student/data/feed_data.dart';

abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedOpportunity> opportunities;
  final List<Map<String, dynamic>> rawOpportunities;
  final Set<String> studentSkills;
  final Set<String> appliedIds;
  final Set<String> bookmarkedIds;
  final String selectedCategory;
  final String studentName;
  final String? studentPhotoUrl;

  FeedLoaded({
    required this.opportunities,
    required this.rawOpportunities,
    required this.studentSkills,
    required this.appliedIds,
    required this.bookmarkedIds,
    this.selectedCategory = 'All',
    this.studentName = '',
    this.studentPhotoUrl,
  });

  FeedLoaded copyWith({
    List<FeedOpportunity>? opportunities,
    List<Map<String, dynamic>>? rawOpportunities,
    Set<String>? studentSkills,
    Set<String>? appliedIds,
    Set<String>? bookmarkedIds,
    String? selectedCategory,
    String? studentName,
    String? studentPhotoUrl,
  }) {
    return FeedLoaded(
      opportunities: opportunities ?? this.opportunities,
      rawOpportunities: rawOpportunities ?? this.rawOpportunities,
      studentSkills: studentSkills ?? this.studentSkills,
      appliedIds: appliedIds ?? this.appliedIds,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      studentName: studentName ?? this.studentName,
      studentPhotoUrl: studentPhotoUrl ?? this.studentPhotoUrl,
    );
  }
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}
