import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/features/startups/bloc/startup_bloc.dart';
import 'package:connect/features/startups/bloc/startup_event.dart';
import 'package:connect/features/startups/bloc/startup_state.dart';
import 'package:connect/features/startups/components/startup_profile_sheet.dart';
import 'package:connect/features/startups/screens/edit_opportunity_screen.dart';

class StartupDashboardScreen extends StatelessWidget {
  final VoidCallback? onNewOpportunity;
  const StartupDashboardScreen({super.key, this.onNewOpportunity});

  Widget _buildStatCard(String count, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(
      BuildContext context, Map<String, dynamic> opportunity) {
    final isOpen = opportunity['isOpen'] == true;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity['title'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${opportunity['applicantsCount'] ?? 0} applicants · ${opportunity['roleType'] ?? ''}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final bloc = context.read<StartupBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditOpportunityScreen(opportunity: opportunity),
                ),
              ).then((_) => bloc.add(LoadDashboard()));
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 16, color: Colors.blue),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isOpen
                  ? const Color(0xFFE8F5E9)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                color: isOpen ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupBloc, StartupState>(
      builder: (context, state) {
        if (state is StartupInitial || state is StartupLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is StartupError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }
        if (state is! StartupLoaded) return const SizedBox.shrink();

        final startup = state.startup;
        final opportunities = state.opportunities;
        final startupName = startup?['name'] ?? 'Your Startup';
        final firstLetter =
            startupName.isNotEmpty ? startupName[0].toUpperCase() : 'S';
        final isVerified = startup?['isVerified'] == true;
        final logoUrl = startup?['logoUrl'] as String?;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                toolbarHeight: 60,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your startup',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      startupName,
                      style: const TextStyle(
                        color: Color(0xFF1E1E2D),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: isVerified
                            ? Colors.green
                            : const Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => StartupProfileSheet.show(
                      context,
                      name: startupName,
                      email: FirebaseAuth.instance.currentUser?.email ?? '',
                      logoUrl: logoUrl,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                          ? NetworkImage(logoUrl)
                          : null,
                      child: (logoUrl == null || logoUrl.isEmpty)
                          ? Text(
                              firstLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildStatCard(
                      opportunities
                          .where((o) => o['isOpen'] == true)
                          .length
                          .toString(),
                      'Active Roles',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      opportunities
                          .fold<int>(
                            0,
                            (sum, o) =>
                                sum + ((o['applicantsCount'] ?? 0) as int),
                          )
                          .toString(),
                      'Applicants',
                      Colors.purple,
                    ),
                    _buildStatCard('0', 'Hired', Colors.green),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Your Opportunities',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onNewOpportunity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('New'),
                      ),
                    ],
                  ),
                ),
              ),
              opportunities.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No opportunities posted yet.\nTap "New" to post your first one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildOpportunityCard(
                            context, opportunities[index]),
                        childCount: opportunities.length,
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }
}
