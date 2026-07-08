import 'package:flutter/material.dart';

class PortfolioLinks extends StatefulWidget {
  final Function(List<String>) onChanged;

  const PortfolioLinks({super.key, required this.onChanged});

  @override
  State<PortfolioLinks> createState() => _PortfolioLinksState();
}

class _PortfolioLinksState extends State<PortfolioLinks> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
    widget.onChanged(_controllers.map((field) => field.text).toList());
  }

  void _removeField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    widget.onChanged(_controllers.map((field) => field.text).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Portfolio Links",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        ..._controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final ctrl = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.link, color: Colors.blue, size: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      hintText: "https://",
                      filled: true,
                      fillColor: Color(0xFFF0F4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => widget.onChanged(
                      _controllers.map((c) => c.text).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red.shade300,
                  ),
                  onPressed: _controllers.length > 1
                      ? () => _removeField(index)
                      : null,
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addField,
          icon: Icon(Icons.add),
          label: Text("Add link"),
        ),
      ],
    );
  }
}
