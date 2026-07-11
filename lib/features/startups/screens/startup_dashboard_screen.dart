import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connect/repositories/startup_repository.dart';

class StartupDashboardScreen extends StatefulWidget {
  final VoidCallback? onNewOpportunity;
  const StartupDashboardScreen({super.key, this.onNewOpportunity});

  @override
  State<StartupDashboardScreen> createState() => _StartupDashboardScreenState();
}

class _StartupDashboardScreenState extends State<StartupDashboardScreen> {
  Map<String, dynamic>? _startup;
  List<Map<String, dynamic>> _opportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final repo = StartupRepository();
      final results = await Future.wait([
        repo.getStartupProfile(uid),
        repo.getStartupOpportunities(uid),
      ]);
      if (mounted) {
        setState(() {
          _startup = results[0] as Map<String, dynamic>?;
          _opportunities = (results[1] as List).cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity) {
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${opportunity['applicantsCount'] ?? 0} applicants · ${opportunity['roleType'] ?? ''}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              opportunity['isOpen'] == true ? 'Open' : 'Closed',
              style: TextStyle(
                color: opportunity['isOpen'] == true
                    ? Colors.green
                    : Colors.grey,
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
    final isVerified = _startup?['isVerified'] == true;
    final startupName = _startup?['name'] ?? 'Your Startup';
    final firstLetter = startupName.isNotEmpty
        ? startupName[0].toUpperCase()
        : 'S';

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  toolbarHeight: 60,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your startup',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
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
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                        _opportunities
                            .where((o) => o['isOpen'] == true)
                            .length
                            .toString(),
                        'Active Roles',
                        Colors.blue,
                      ),
                      _buildStatCard(
                        _opportunities
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: widget.onNewOpportunity,
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
                _opportunities.isEmpty
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
                          (context, index) =>
                              _buildOpportunityCard(_opportunities[index]),
                          childCount: _opportunities.length,
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }
}
