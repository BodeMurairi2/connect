import 'package:flutter/material.dart';

class Applicant {
  final String firstName;
  final String lastName;
  final String role;
  final String fieldStudy;
  final String status;
  final Color avatarColor;

  const Applicant({
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.fieldStudy,
    required this.status,
    required this.avatarColor,
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
    fieldStudy: 'Software Engineering',
    status: 'Pending',
    avatarColor: Colors.orange,
  ),
  Applicant(
    firstName: 'Kwame',
    lastName: 'Mensah',
    role: 'UI/UX Design Intern',
    fieldStudy: 'Entrepreneurial Leadership',
    status: 'Reviewing',
    avatarColor: Colors.blue,
  ),
  Applicant(
    firstName: 'Fatima',
    lastName: 'Osei',
    role: 'Marketing Lead',
    fieldStudy: 'Entrepreneurial Leadership',
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
