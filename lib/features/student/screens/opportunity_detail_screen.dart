import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/student/components/opportunity_detail_header.dart';
import 'package:connect/features/student/components/opportunity_skills_section.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final FeedOpportunity opportunity;
  final Map<String, dynamic>? applicationData;
  const OpportunityDetailScreen({
    super.key,
    required this.opportunity,
    this.applicationData,
  });

  Widget _buildSubmissionSheet(Map<String, dynamic> app) {
    final status = app['status'] as String? ?? 'Pending';
    final coverLetter = app['coverLetter'] as String? ?? '';
    final cvUrl = app['cvUrl'] as String?;
    final coverLetterFileUrl = app['coverLetterFileUrl'] as String?;

    final statusColors = {
      'Pending':   (bg: const Color(0xFFFFF8E1), text: const Color(0xFFE65100)),
      'Reviewing': (bg: const Color(0xFFE3F2FD), text: Colors.blue),
      'Accepted':  (bg: const Color(0xFFE8F5E9), text: Colors.green),
      'Declined':  (bg: const Color(0xFFFFEBEE), text: Colors.red),
    };
    final sc = statusColors[status] ??
        (bg: Colors.grey.shade100, text: Colors.grey as Color);

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Your Application',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: sc.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: sc.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (coverLetter.isNotEmpty) ...[
            Text(
              coverLetter,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              _docBadge('CV', cvUrl != null),
              const SizedBox(width: 8),
              _docBadge('Cover Letter Doc', coverLetterFileUrl != null),
            ],
          ),
        ],
      );
  }

  Widget _docBadge(String label, bool uploaded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: uploaded
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: uploaded
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(uploaded ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 14,
              color: uploaded ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: uploaded ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          OpportunityDetailHeader(opportunity: opportunity),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (opportunity.deadline != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: DateTime.now().isAfter(opportunity.deadline!)
                            ? Colors.red.withValues(alpha: 0.08)
                            : Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: DateTime.now().isAfter(opportunity.deadline!)
                                ? Colors.red
                                : Colors.deepOrange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateTime.now().isAfter(opportunity.deadline!)
                                ? 'Deadline has passed (${opportunity.deadline!.day}/${opportunity.deadline!.month}/${opportunity.deadline!.year})'
                                : 'Apply by ${opportunity.deadline!.day}/${opportunity.deadline!.month}/${opportunity.deadline!.year}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DateTime.now().isAfter(opportunity.deadline!)
                                  ? Colors.red
                                  : Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(opportunity.domain, Colors.blue),
                      _buildTag(opportunity.compensation, Colors.green),
                      _buildTag(opportunity.duration, Colors.black),
                      _buildTag(opportunity.location, Colors.orange),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'About this role',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Now Add opportunity description
                  Text(
                    opportunity.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  // Now skills section and matche skills from list of opportunityskills and matchskills
                  OpportunitySkillsSection(
                    skills: opportunity.skills,
                    matchedSkills: opportunity.matchedSkills,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Roles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...opportunity.responsibilities.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '•  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (opportunity.contactEmail.isNotEmpty ||
                      opportunity.contactPhone.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Contact the Startup',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (opportunity.contactEmail.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            opportunity.contactEmail,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    if (opportunity.contactPhone.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            opportunity.contactPhone,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ],
                  if (applicationData != null) ...[
                    const SizedBox(height: 24),
                    _buildSubmissionSheet(applicationData!),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: applicationData != null
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(
                      '/student/opportunity/apply',
                      extra: opportunity),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply Now',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
    );
  }
}
