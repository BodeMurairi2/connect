import 'package:flutter/material.dart';

class SkillsSelector extends StatefulWidget {
  final List<String> skills;
  final Set<String>? initialSelected;
  final Function(Set<String>) onChanged;

  const SkillsSelector({
    super.key,
    required this.skills,
    this.initialSelected,
    required this.onChanged,
  });

  @override
  State<SkillsSelector> createState() => _SkillsSelectorState();
}

class _SkillsSelectorState extends State<SkillsSelector> {
  final Set<String> _selected = {};
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.skills);
    if (widget.initialSelected != null) {
      _selected.addAll(widget.initialSelected!);
      for (final s in widget.initialSelected!) {
        if (!_skills.contains(s)) _skills.add(s);
      }
    }
  }

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
            ..._skills.map(
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
              onPressed: () async {
                final controller = TextEditingController();
                final skill = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Skill'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'e.g. Swift'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, controller.text.trim()),
                        child: const Text('Add', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                );
                if (skill != null && skill.isNotEmpty) {
                  setState(() {
                    if (!_skills.contains(skill)) _skills.add(skill);
                    _selected.add(skill);
                    widget.onChanged(_selected);
                  });
                }
              },
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
