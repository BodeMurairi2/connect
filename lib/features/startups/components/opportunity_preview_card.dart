import 'package:flutter/material.dart';

class OpportunityPreviewCard extends StatelessWidget {
  final String startupName;
  final TextEditingController titleController;
  final VoidCallback? onTap;

  const OpportunityPreviewCard({
    super.key,
    required this.startupName,
    required this.titleController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: titleController,
      builder: (context, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  startupName.isNotEmpty ? startupName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startupName.isEmpty ? 'Your Startup' : startupName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      titleController.text.isEmpty
                          ? 'Role title will appear here'
                          : titleController.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
