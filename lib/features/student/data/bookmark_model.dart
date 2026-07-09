import 'package:connect/features/student/data/feed_data.dart';

class BookMark {
  final FeedOpportunity opportunity;
  final String savedAt;
  final bool isApplied;

  const BookMark({
    required this.opportunity,
    required this.savedAt,
    this.isApplied = false,
  });
}

final List<BookMark> bookmarks = [
  BookMark(opportunity: feedOpportunities[1], savedAt: '2d ago'),
  BookMark(
    opportunity: feedOpportunities[0],
    savedAt: '5d ago',
    isApplied: true,
  ),
  BookMark(opportunity: feedOpportunities[3], savedAt: '1w ago'),
];
