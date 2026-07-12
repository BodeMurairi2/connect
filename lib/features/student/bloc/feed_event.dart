abstract class FeedEvent {}

class LoadFeed extends FeedEvent {
  final String uid;
  LoadFeed(this.uid);
}

// Internal — emitted by stream subscriptions inside FeedBloc
class AppliedIdsUpdated extends FeedEvent {
  final Set<String> ids;
  AppliedIdsUpdated(this.ids);
}

class BookmarkedIdsUpdated extends FeedEvent {
  final Set<String> ids;
  BookmarkedIdsUpdated(this.ids);
}

class FeedCategoryChanged extends FeedEvent {
  final String category;
  FeedCategoryChanged(this.category);
}

class ToggleBookmark extends FeedEvent {
  final String opportunityId;
  ToggleBookmark(this.opportunityId);
}
