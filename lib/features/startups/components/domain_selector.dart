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
  final List<String> _customDomains = [];

  void _showAddDomainDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add custom domain"),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: "e.g. Cleantech"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _customDomains.add(value);
                  _selected = value;
                  widget.onChanged(_selected);
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDomains = [...widget.domains, ..._customDomains];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...allDomains.map((domain) {
          final isSelected = _selected == domain;
          return ChoiceChip(
            label: Text(domain),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _selected = isSelected ? null : domain;
                widget.onChanged(_selected);
              });
            },
            selectedColor: Colors.blue,
            backgroundColor: Colors.grey.shade100,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          );
        }),
        ActionChip(
          label: const Text("+ Other"),
          onPressed: _showAddDomainDialog,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade400),
          ),
          labelStyle:
              TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
      ],
    );
  }
}
