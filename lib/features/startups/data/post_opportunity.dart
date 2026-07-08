import 'package:flutter/material.dart';

enum OpportunityType { internship, job, shortTermContract }

enum LocationType { remote, inPerson }

class PostOpportunity {
  final String title;
  final OpportunityType opportunityType;
  final String role;
  final String description;
  final List<String> skills;
  final String requirements;
  final DateTime expectedStartingDate;
  final String duration;
  final String compensation;
  final String? salary;
  final LocationType locationType;
  final String? address;
  final String startupName;
  final Color startupColor;

  const PostOpportunity({
    required this.title,
    required this.opportunityType,
    required this.role,
    required this.description,
    required this.skills,
    required this.requirements,
    required this.expectedStartingDate,
    required this.duration,
    required this.compensation,
    this.salary,
    required this.locationType,
    this.address,
    required this.startupName,
    required this.startupColor,
  });
}

const List<String> roleTypes = [
  'Engineering',
  'Design',
  'Marketing',
  'Operations',
  'Research',
  'Content',
  'Business',
];

const List<String> opportunitySkills = [
  'Node.js',
  'PostgreSQL',
  'REST APIs',
  'Flutter',
  'Python',
  'React',
  'UI/UX',
];

const List<String> durations = ['1 month', '3 months', '6 months', '1 year'];

const List<String> compensations = ['Paid', 'Unpaid', 'Stipend'];

const List<String> currencies = [
  'USD',
  'FrW',
  'KES',
  'UGX',
  'CDF',
  'XAF',
  'NGN',
];
