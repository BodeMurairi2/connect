import 'package:cloud_firestore/cloud_firestore.dart';
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
  final DateTime? deadline;
  final String contactEmail;
  final String contactPhone;

  const FeedOpportunity({
    this.opportunityId = '',
    this.startupUid = '',
    this.deadline,
    this.contactEmail = '',
    this.contactPhone = '',
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

/// Maps a raw Firestore map to a FeedOpportunity.
/// Pass [studentSkills] (the student's own skills list) to compute skill matching.
/// An opportunity is "recommended" when skillsMatch >= 50.
FeedOpportunity mapToFeedOpportunity(
  Map<String, dynamic> map, {
  Set<String> studentSkills = const {},
}) {
  final name = map['startupName'] as String? ?? '';
  final deadlineRaw = map['deadline'];
  final deadline =
      deadlineRaw != null ? (deadlineRaw as Timestamp).toDate() : null;
  final skills = List<String>.from(map['skills'] ?? []);

  final normalizedStudent = studentSkills.map((s) => s.toLowerCase()).toSet();
  final matched =
      skills.where((s) => normalizedStudent.contains(s.toLowerCase())).toList();
  final matchPct =
      skills.isEmpty ? 0 : (matched.length * 100 ~/ skills.length);

  return FeedOpportunity(
    opportunityId: map['id'] as String? ?? '',
    startupUid: map['startupUid'] as String? ?? '',
    startupName: name,
    role: map['title'] as String? ?? '',
    domain: map['roleType'] as String? ?? '',
    compensation: map['compensation'] as String? ?? '',
    duration: map['duration'] as String? ?? '',
    location: map['locationType'] as String? ?? '',
    description: map['description'] as String? ?? '',
    skills: skills,
    avatarColor:
        Colors.primaries[name.hashCode.abs() % Colors.primaries.length],
    isVerified: false,
    skillsMatch: matchPct,
    postedAt: 'recently',
    matchedSkills: matched,
    responsibilities: [],
    deadline: deadline,
    contactEmail: map['contactEmail'] as String? ?? '',
    contactPhone: map['contactPhone'] as String? ?? '',
  );
}

const List<String> feedCategories = [
  'All',
  'Engineering',
  'Design',
  'Marketing',
  'Research',
  'Business',
];
