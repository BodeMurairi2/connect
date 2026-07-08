import 'package:flutter/material.dart';

class Applicant {
  final String firstName;
  final String lastName;
  final String role;
  final String fieldStudy;
  final String status;
  final Color avatarColor;
  final String year;
  final List<String> skills;
  final String bio;

  const Applicant({
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.fieldStudy,
    required this.status,
    required this.avatarColor,
    required this.year,
    required this.skills,
    required this.bio,
  });
}

class Opportunity {
  final String title;
  final String meta;
  const Opportunity({required this.title, required this.meta});
}

final List<Applicant> applicants = [
  Applicant(
    firstName: 'Amara',
    lastName: 'Diallo',
    role: 'Flutter Developer Intern',
    fieldStudy: 'CS',
    year: 'Year 3',
    skills: ['Flutter', 'Firebase', 'Dart'],
    bio: "I've built three Flutter apps and contributed to open source...",
    status: 'Pending',
    avatarColor: Colors.orange,
  ),
  Applicant(
    firstName: 'Bode',
    lastName: 'Murairi',
    role: 'Flutter Developer Intern',
    fieldStudy: 'CS',
    year: 'Year 3',
    skills: ['Flutter', 'Firebase', 'Python'],
    bio: 'Passionate mobile dev with hands-on experience in Flutter...',
    status: 'Reviewing',
    avatarColor: Colors.purple,
  ),
  Applicant(
    firstName: 'Fatima',
    lastName: 'Osei',
    role: 'Marketing Lead',
    fieldStudy: 'SE',
    year: 'Year 4',
    skills: ['Flutter', 'Dart', 'UI/UX'],
    bio: 'Experienced Flutter dev with 2 published apps on Play Store...',
    status: 'Accepted',
    avatarColor: Colors.green,
  ),
];

final List<Opportunity> opportunities = [
  Opportunity(
    title: 'Flutter Developer Intern',
    meta: '12 applicants · Posted 2d ago',
  ),
  Opportunity(
    title: 'UI/UX Design Intern',
    meta: '8 applicants · Posted 5d ago',
  ),
];
