import 'package:flutter/material.dart';

class FeedOpportunity {
  final String opportunityId;
  final String startupUid;
  final String startupName;
  final String role;
  final String domain;
  final String compensation;
  final String duration;
  final String location;
  final Color avatarColor;
  final bool isVerified;
  final int skillsMatch;
  final String postedAt;
  final String description;
  final List<String> skills;
  final List<String> matchedSkills;
  final List<String> responsibilities;

  const FeedOpportunity({
    this.opportunityId = '',
    this.startupUid = '',
    required this.startupName,
    required this.role,
    required this.domain,
    required this.compensation,
    required this.duration,
    required this.location,
    required this.avatarColor,
    required this.isVerified,
    required this.skillsMatch,
    required this.postedAt,
    required this.description,
    required this.skills,
    required this.matchedSkills,
    required this.responsibilities,
  });
}

final List<FeedOpportunity> feedOpportunities = [
  FeedOpportunity(
    startupName: 'TechBridge Africa',
    role: 'Flutter Developer Intern',
    domain: 'Engineering',
    compensation: 'Paid',
    duration: '3 months',
    location: 'Remote',
    avatarColor: Colors.blue,
    isVerified: true,
    skillsMatch: 3,
    postedAt: '2h ago',
    description:
        "We're looking for a passionate Flutter developer intern to join our mobile team. You'll work directly with our lead engineer to build features for our education platform used by students across Africa.",
    skills: ['Flutter', 'Firebase', 'Dart', 'REST APIs', 'Git'],
    matchedSkills: ['Flutter', 'Firebase', 'Dart'],
    responsibilities: [
      'Build and maintain mobile app features',
      'Collaborate on UI/UX implementation',
      'Write clean, maintainable Dart code',
      'Participate in code reviews',
    ],
  ),
  FeedOpportunity(
    startupName: 'AgriConnect',
    role: 'UI/UX Design Intern',
    domain: 'Design',
    compensation: 'Equity',
    duration: '6 weeks',
    location: 'Remote',
    avatarColor: Colors.green,
    isVerified: true,
    skillsMatch: 2,
    postedAt: '1d ago',
    description:
        'AgriConnect is building the future of African agriculture. We need a creative UI/UX intern to help design intuitive interfaces for farmers and agri-businesses across the continent.',
    skills: ['Figma', 'UI/UX', 'Prototyping', 'User Research', 'Adobe XD'],
    matchedSkills: ['Figma', 'UI/UX'],
    responsibilities: [
      'Design wireframes and prototypes',
      'Conduct user research sessions',
      'Maintain the design system',
      'Collaborate with developers on implementation',
    ],
  ),
  FeedOpportunity(
    startupName: 'FinFlow',
    role: 'Marketing Lead',
    domain: 'Marketing',
    compensation: 'Stipend',
    duration: '4 months',
    location: 'In Person',
    avatarColor: Colors.orange,
    isVerified: false,
    skillsMatch: 0,
    postedAt: '3d ago',
    description:
        'FinFlow is a fintech startup helping young Africans manage and grow their money. We are looking for a marketing lead to own our content and growth strategy.',
    skills: ['Content Marketing', 'Social Media', 'SEO', 'Analytics'],
    matchedSkills: [],
    responsibilities: [
      'Own the content calendar and social media channels',
      'Run growth experiments and track KPIs',
      'Collaborate with the product team on messaging',
    ],
  ),
  FeedOpportunity(
    startupName: 'EduPay',
    role: 'Mobile App Developer',
    domain: 'Engineering',
    compensation: 'Paid',
    duration: '6 months',
    location: 'Remote',
    avatarColor: Colors.purple,
    isVerified: true,
    skillsMatch: 4,
    postedAt: '5d ago',
    description:
        'EduPay makes education payments seamless across Africa. Join our engineering team to build and scale the mobile experience for thousands of students and institutions.',
    skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git'],
    matchedSkills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
    responsibilities: [
      'Develop new features for the EduPay mobile app',
      'Integrate payment APIs and third-party services',
      'Write unit and integration tests',
      'Work closely with the backend team',
    ],
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
