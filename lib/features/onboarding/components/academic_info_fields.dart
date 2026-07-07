import 'package:flutter/material.dart';

class AcademicInfoFields extends StatelessWidget {
  final String? selectedYear;
  final String? selectedMajor;
  final Function(String?) onYearChanged;
  final Function(String?) onMajorChanged;

  const AcademicInfoFields({
    super.key,
    required this.selectedMajor,
    required this.selectedYear,
    required this.onYearChanged,
    required this.onMajorChanged,
  });
  static const _years = ['Year 1', 'Year 2', 'Year 3', 'Year 4'];
  static const _majors = [
    'Software Engineering',
    'Entrepreneurial Leadership',
    'Global Challenges',
  ];

  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  static final _fieldDecoration = InputDecoration(
    filled: true,
    fillColor: Color(0xFFF0F4FF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Academic Year", style: _labelStyle),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                onChanged: onYearChanged,
                decoration: _fieldDecoration,
                items: _years
                    .map(
                      (year) =>
                          DropdownMenuItem(value: year, child: Text(year)),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Major", style: _labelStyle),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedMajor,
                onChanged: onMajorChanged,
                decoration: _fieldDecoration,
                items: _majors
                    .map(
                      (major) =>
                          DropdownMenuItem(value: major, child: Text(major)),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
