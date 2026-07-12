import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/features/student/bloc/feed_bloc.dart';
import 'package:connect/features/student/bloc/feed_event.dart';
import 'package:connect/features/student/bloc/feed_state.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/student/components/feed_headers.dart';
import 'package:connect/features/student/components/feed_stats_row.dart';
import 'package:connect/features/student/components/opportunity_card.dart';

class FeedScreen extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const FeedScreen({super.key, this.onSeeAll});

  List<({FeedOpportunity opportunity, Map<String, dynamic> raw})> _filterBy(
    FeedLoaded state,
    List<FeedOpportunity> list,
  ) {
    final result =
        <({FeedOpportunity opportunity, Map<String, dynamic> raw})>[];
    for (var i = 0; i < state.opportunities.length; i++) {
      final o = state.opportunities[i];
      if (!list.contains(o)) continue;
      if (state.selectedCategory == 'All' ||
          o.domain == state.selectedCategory) {
        result.add(
            (opportunity: o, raw: state.rawOpportunities[i]));
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
    BuildContext context,
    FeedLoaded state,
    List<({FeedOpportunity opportunity, Map<String, dynamic> raw})> items,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return OpportunityCard(
              opportunity: item.opportunity,
              featured: index == 0,
              isApplied:
                  state.appliedIds.contains(item.opportunity.opportunityId),
              isBookmarked: state.bookmarkedIds
                  .contains(item.opportunity.opportunityId),
              onBookmark: () => context.read<FeedBloc>().add(
                    ToggleBookmark(item.opportunity.opportunityId),
                  ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F4F9),
            body: Center(child: Text(state.message)),
          );
        }

        final loaded = state is FeedLoaded ? state : null;
        final isLoading = state is FeedLoading || state is FeedInitial;

        final recommended = loaded?.opportunities
                .where((o) => o.skillsMatch >= 50)
                .toList() ??
            [];
        final others = loaded?.opportunities
                .where((o) => o.skillsMatch < 50)
                .toList() ??
            [];
        final filteredRecommended = loaded != null
            ? _filterBy(loaded, recommended)
            : <({FeedOpportunity opportunity, Map<String, dynamic> raw})>[];
        final filteredOthers = loaded != null
            ? _filterBy(loaded, others)
            : <({FeedOpportunity opportunity, Map<String, dynamic> raw})>[];
        final hasRecommended = (loaded?.studentSkills.isNotEmpty ?? false) &&
            filteredRecommended.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F4F9),
          body: CustomScrollView(
            slivers: [
              FeedHeaderSliver(
                studentName: loaded?.studentName ?? '',
                photoUrl: loaded?.studentPhotoUrl,
              ),
              FeedSearchSliver(
                selectedCategory: loaded?.selectedCategory ?? 'All',
                onCategoryChanged: (category) => context
                    .read<FeedBloc>()
                    .add(FeedCategoryChanged(category)),
              ),
              FeedStatsRow(
                openCount: loaded?.opportunities.length ?? 0,
                appliedCount: loaded?.appliedIds.length ?? 0,
              ),
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (loaded != null) ...[
                if (hasRecommended) ...[
                  SliverToBoxAdapter(
                    child: _sectionHeader(
                      'Recommended for You ⚡',
                      trailing: GestureDetector(
                        onTap: onSeeAll,
                        child: const Text(
                          'See all',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  _cardSliver(context, loaded, filteredRecommended),
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
                        onTap: onSeeAll,
                        child: const Text(
                          'See all',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                _cardSliver(
                  context,
                  loaded,
                  hasRecommended
                      ? filteredOthers
                      : _filterBy(loaded, loaded.opportunities),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}
