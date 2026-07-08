import 'package:flutter/material.dart';

class DomainSelector extends StatefulWidget {
  final List<String> domains;
  final Function(String?) onChanged;

  const DomainSelector({
    super.key,
    required this.domains,
    required this.onChanged,
  });

  @override
  State<DomainSelector> createState() => _DomainSelectorState();
}

class _DomainSelectorState extends State<DomainSelector> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Domain",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.domains.map((domain) {
            final isSelected = _selected == domain;
            return ChoiceChip(
              label: Text(domain),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selected = isSelected ? null : domain;
                  widget.onChanged(_selected);
                });
              },
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
