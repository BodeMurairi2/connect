import 'package:connect/features/startups/bloc/startup_bloc.dart';
import 'package:connect/features/startups/bloc/startup_event.dart';
import 'package:connect/features/startups/bloc/startup_state.dart';
import 'package:connect/features/startups/screens/application_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  String _selectedFilter = 'All';
  static const _filters = ['All', 'Pending', 'Reviewing', 'Accepted', 'Declined'];

  Color _avatarColor(String name) {
    final colors = [
      Colors.orange, Colors.purple, Colors.blue,
      Colors.green, Colors.red, Colors.teal,
    ];
    if (name.isEmpty) return Colors.grey;
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  Widget _buildStatusBadge(String status) {
    final colors = {
      'Pending':   (bg: const Color(0xFFFFF8E1), text: const Color(0xFFE65100)),
      'Reviewing': (bg: const Color(0xFFE3F2FD), text: Colors.blue),
      'Accepted':  (bg: const Color(0xFFE8F5E9), text: Colors.green),
      'Declined':  (bg: const Color(0xFFFFEBEE), text: Colors.red),
    };
    final sc = colors[status] ??
        (bg: Colors.grey.shade100, text: Colors.grey as Color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: sc.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: sc.text, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Widget> _buildActionButtons(
      BuildContext context, Map<String, dynamic> app) {
    final status = app['status'] as String? ?? 'Pending';

    void update(String newStatus) {
      context.read<StartupBloc>().add(
            UpdateApplicantStatus(app: app, newStatus: newStatus),
          );
    }

    switch (status) {
      case 'Pending':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => update('Declined'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Decline"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => update('Reviewing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Review"),
            ),
          ),
        ];
      case 'Reviewing':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => update('Declined'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Decline"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => update('Accepted'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Accept"),
            ),
          ),
        ];
      case 'Accepted':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => update('Declined'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Revoke"),
            ),
          ),
        ];
      case 'Declined':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => update('Reviewing'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Reconsider"),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildApplicantCard(
      BuildContext context, Map<String, dynamic> app) {
    final status = app['status'] as String? ?? 'Pending';
    final isAccepted = status == 'Accepted';
    final name = app['studentName'] as String? ?? 'Unknown';
    final opportunityTitle = app['opportunityTitle'] as String? ?? '';
    final coverLetter = app['coverLetter'] as String? ?? '';
    final email = app['studentEmail'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(application: app),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: isAccepted ? Colors.green : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: _avatarColor(name),
                              child: Text(
                                _initials(name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text(opportunityTitle,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  if (email.isNotEmpty)
                                    Text(email,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey)),
                                ],
                              ),
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        if (coverLetter.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            coverLetter,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(children: _buildActionButtons(context, app)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartupBloc, StartupState>(
      listener: (context, state) {
        if (state is StartupLoaded && state.statusUpdateError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${state.statusUpdateError}')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is StartupLoading ||
            (state is StartupLoaded && state.applicantsLoading);
        final applications =
            state is StartupLoaded ? (state.applications ?? []) : [];
        final filtered = _selectedFilter == 'All'
            ? applications
            : applications
                .where((a) => a['status'] == _selectedFilter)
                .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text("Applicants",
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            actions: [
              IconButton(
                onPressed: () =>
                    context.read<StartupBloc>().add(LoadApplicants()),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedFilter = filter),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        '${filtered.length} applicant${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                applications.isEmpty
                                    ? "No applications yet"
                                    : "No applicants in this category",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 8, 16, 16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) =>
                                  _buildApplicantCard(
                                      context, filtered[index]),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
