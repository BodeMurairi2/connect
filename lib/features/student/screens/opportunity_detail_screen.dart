import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/student/components/opportunity_detail_header.dart';
import 'package:connect/features/student/components/opportunity_skills_section.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final FeedOpportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

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
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                context.push('/student/opportunity/apply', extra: opportunity),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Apply Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
