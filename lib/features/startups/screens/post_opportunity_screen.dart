import 'package:flutter/material.dart';
import 'package:connect/features/startups/components/domain_selector.dart';
import 'package:connect/features/onboarding/components/skills_selector.dart';
import 'package:connect/features/startups/data/post_opportunity.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  String? _selectedRoleType;
  OpportunityType? _selectedOpportunityType;
  Set<String> _selectedSkills = {};
  String? _selectedDuration;
  String? _selectedCompensation;
  LocationType? _locationType;
  final TextEditingController _addressController = TextEditingController();
  String _selectedCurrency = 'FrW';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildLocationChip(String label, LocationType type) {
    final isSelected = _locationType == type;
    return GestureDetector(
      onTap: () => setState(() => _locationType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Post Opportunity",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  "Role Title",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "e.g. Marketing Intern",
                    filled: true,
                    fillColor: Color(0xFFF0F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Role Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                DomainSelector(
                  domains: roleTypes,
                  onChanged: (value) =>
                      setState(() => _selectedRoleType = value),
                ),
                SizedBox(height: 16),
                Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Describe the role and responsabilities",
                    filled: true,
                    fillColor: Color(0xFFF0F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SkillsSelector(
                  skills: opportunitySkills,
                  onChanged: (selected) =>
                      setState(() => _selectedSkills = selected),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Duration",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDuration,
                            onChanged: (value) =>
                                setState(() => _selectedDuration = value),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF0F4FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: durations
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
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
                          Text(
                            "Compensation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCompensation,
                            onChanged: (value) =>
                                setState(() => _selectedCompensation = value),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF0F4FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: compensations
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Expected Salary (FrW) — Optional",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "e.g. 50000",
                    filled: true,
                    fillColor: Color(0xFFF0F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefix: DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      isDense: true,
                      onChanged: (value) =>
                          setState(() => _selectedCurrency = value!),
                      items: currencies
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Location",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLocationChip("Remote", LocationType.remote),
                    const SizedBox(width: 8),
                    _buildLocationChip("In Person", LocationType.inPerson),
                  ],
                ),
                if (_locationType == LocationType.inPerson) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "Startup Address",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: "e.g. KG 123 St, Kigali",
                      filled: true,
                      fillColor: const Color(0xFFF0F4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  "Preview",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
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
                        child: const Text(
                          "T",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "TechBridge Africa",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            _titleController.text.isEmpty
                                ? "Role title will appear here"
                                : _titleController.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Post Opportunity",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
