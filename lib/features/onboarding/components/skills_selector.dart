import 'package:flutter/material.dart';

class SkillsSelector extends StatefulWidget {
  final List<String> skills;
  final Function(Set<String>) onChanged;

  const SkillsSelector({
    super.key,
    required this.skills,
    required this.onChanged,
  });

  @override
  State<SkillsSelector> createState() => _SkillsSelectorState();
}

class _SkillsSelectorState extends State<SkillsSelector> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Skills",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.skills.map(
              (skill) => FilterChip(
                label: Text(skill),
                selected: _selected.contains(skill),
                onSelected: (val) {
                  setState(() {
                    val ? _selected.add(skill) : _selected.remove(skill);
                    widget.onChanged(_selected);
                  });
                },
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: _selected.contains(skill)
                      ? Colors.white
                      : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            ActionChip(
              label: Text("+ Add more"),
              onPressed: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
