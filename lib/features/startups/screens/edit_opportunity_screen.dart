import 'package:flutter/material.dart';
import 'package:connect/features/startups/components/domain_selector.dart';
import 'package:connect/features/onboarding/components/skills_selector.dart';
import 'package:connect/features/startups/data/post_opportunity.dart';
import 'package:connect/repositories/opportunity_repository.dart';

class EditOpportunityScreen extends StatefulWidget {
  final Map<String, dynamic> opportunity;
  const EditOpportunityScreen({super.key, required this.opportunity});

  @override
  State<EditOpportunityScreen> createState() => _EditOpportunityScreenState();
}

class _EditOpportunityScreenState extends State<EditOpportunityScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _salaryController;
  late final TextEditingController _addressController;

  String? _selectedRoleType;
  Set<String> _selectedSkills = {};
  String? _selectedDuration;
  String? _selectedCompensation;
  LocationType? _locationType;
  String _selectedCurrency = 'FrW';
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    final o = widget.opportunity;
    _titleController = TextEditingController(text: o['title'] ?? '');
    _descriptionController = TextEditingController(text: o['description'] ?? '');
    _salaryController = TextEditingController(text: o['salary'] ?? '');
    _addressController = TextEditingController(text: o['address'] ?? '');
    _selectedRoleType = o['roleType'] as String?;
    _selectedSkills = Set<String>.from(
      (o['skills'] as List<dynamic>? ?? []).cast<String>(),
    );
    _selectedDuration = o['duration'] as String?;
    _selectedCompensation = o['compensation'] as String?;
    _selectedCurrency = (o['currency'] as String?) ?? 'FrW';
    _isOpen = o['isOpen'] as bool? ?? true;
    final locType = o['locationType'] as String?;
    _locationType =
        locType == 'remote' ? LocationType.remote : LocationType.inPerson;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role type')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await OpportunityRepository().updateOpportunity(
        widget.opportunity['id'] as String,
        title: _titleController.text.trim(),
        roleType: _selectedRoleType!,
        description: _descriptionController.text.trim(),
        skills: _selectedSkills.toList(),
        duration: _selectedDuration ?? '',
        compensation: _selectedCompensation ?? '',
        currency: _selectedCurrency,
        salary: _salaryController.text.trim(),
        locationType:
            _locationType == LocationType.remote ? 'remote' : 'inPerson',
        address: _addressController.text.trim(),
        isOpen: _isOpen,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Opportunity updated!')),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Edit Opportunity',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Status toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isOpen
                          ? const Color(0xFFE8F5E9)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isOpen ? Icons.lock_open : Icons.lock_outline,
                          color: _isOpen ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isOpen
                                ? 'Open — accepting applications'
                                : 'Closed — not accepting applications',
                            style: TextStyle(
                              color: _isOpen ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isOpen,
                          onChanged: (v) => setState(() => _isOpen = v),
                          activeThumbColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Role Title',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF0F4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Role title is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Role Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DomainSelector(
                    domains: roleTypes,
                    initialValue: _selectedRoleType,
                    onChanged: (v) => setState(() => _selectedRoleType = v),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF0F4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Description is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  SkillsSelector(
                    skills: opportunitySkills,
                    initialSelected: _selectedSkills,
                    onChanged: (s) => setState(() => _selectedSkills = s),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Duration',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: durations.contains(_selectedDuration)
                                  ? _selectedDuration
                                  : null,
                              onChanged: (v) =>
                                  setState(() => _selectedDuration = v),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF0F4FF),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Compensation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: compensations.contains(_selectedCompensation)
                                  ? _selectedCompensation
                                  : null,
                              onChanged: (v) =>
                                  setState(() => _selectedCompensation = v),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF0F4FF),
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
                    'Expected Salary — Optional',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 50000',
                      filled: true,
                      fillColor: const Color(0xFFF0F4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefix: DropdownButton<String>(
                        value: _selectedCurrency,
                        underline: const SizedBox(),
                        isDense: true,
                        onChanged: (v) =>
                            setState(() => _selectedCurrency = v!),
                        items: currencies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLocationChip('Remote', LocationType.remote),
                      const SizedBox(width: 8),
                      _buildLocationChip('In Person', LocationType.inPerson),
                    ],
                  ),
                  if (_locationType == LocationType.inPerson) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Startup Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'e.g. KG 123 St, Kigali',
                        filled: true,
                        fillColor: const Color(0xFFF0F4FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
