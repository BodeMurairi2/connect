import 'package:flutter/material.dart';

class FeedOpportunity {
  final String startupName;
  final String role;
  final String domain;
  final String compensation;
  final String duration;
  final Color avatarColor;
  final bool isVerified;
  final int skillsMatch;
  final String postedAt;

  const FeedOpportunity({
    required this.startupName,
    required this.role,
    required this.domain,
    required this.compensation,
    required this.duration,
    required this.avatarColor,
    required this.isVerified,
    required this.skillsMatch,
    required this.postedAt,
  });
}

final List<FeedOpportunity> feedOpportunities = [
  FeedOpportunity(
    startupName: 'TechBridge Africa',
    role: 'Flutter Developer Intern',
    domain: 'Engineering',
    compensation: 'Paid',
    duration: '3 months',
    avatarColor: Colors.blue,
    isVerified: true,
    skillsMatch: 3,
    postedAt: '2h ago',
  ),
  FeedOpportunity(
    startupName: 'AgriConnect',
    role: 'UI/UX Design Intern',
    domain: 'Design',
    compensation: 'Equity',
    duration: '6 weeks',
    avatarColor: Colors.green,
    isVerified: true,
    skillsMatch: 2,
    postedAt: '1d ago',
  ),
  FeedOpportunity(
    startupName: 'FinFlow',
    role: 'Marketing Lead',
    domain: 'Marketing',
    compensation: 'Stipend',
    duration: '4 months',
    avatarColor: Colors.orange,
    isVerified: false,
    skillsMatch: 0,
    postedAt: '3d ago',
  ),
  FeedOpportunity(
    startupName: 'EduPay',
    role: 'Mobile App Developer',
    domain: 'Engineering',
    compensation: 'Paid',
    duration: '6 months',
    avatarColor: Colors.purple,
    isVerified: true,
    skillsMatch: 4,
    postedAt: '5d ago',
  ),
];

const List<String> feedCategories = [
  'All',
  'Engineering',
  'Design',
  'Marketing',
  'Research',
  'Business',
];
