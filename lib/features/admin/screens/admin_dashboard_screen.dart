import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connect/repositories/auth_repository.dart';
import 'package:connect/repositories/startup_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> _startups = [];
  bool _loading = true;
  String _filter = 'Pending';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await StartupRepository().getAllStartups();
    if (mounted) setState(() { _startups = all; _loading = false; });
  }

  Future<void> _setVerified(Map<String, dynamic> startup, bool verified) async {
    final uid = startup['uid'] as String? ?? startup['id'] as String;
    await StartupRepository().setVerified(uid, verified: verified);
    await _load();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _startups;
    if (_filter == 'Verified') {
      return _startups.where((s) => s['isVerified'] == true).toList();
    }
    return _startups.where((s) => s['isVerified'] != true).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin — Startup Verification',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) context.go('/role-selection');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            _filter == 'Pending'
                                ? 'No pending startups'
                                : 'No startups found',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) =>
                              _buildCard(_filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    const filters = ['Pending', 'Verified', 'All'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: filters.map((f) {
          final selected = _filter == f;
          final count = f == 'All'
              ? _startups.length
              : f == 'Verified'
                  ? _startups.where((s) => s['isVerified'] == true).length
                  : _startups.where((s) => s['isVerified'] != true).length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '$f ($count)',
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> startup) {
    final name = startup['name'] as String? ?? 'Unknown';
    final field = startup['field'] as String? ?? '';
    final description = startup['description'] as String? ?? '';
    final founderName = startup['founderName'] as String? ?? '';
    final location = startup['location'] as String? ?? '';
    final website = startup['website'] as String? ?? '';
    final teamSize = startup['teamSize'];
    final logoUrl = startup['logoUrl'] as String?;
    final certUrl = startup['businessCertificateUrl'] as String? ?? '';
    final aluUrl = startup['aluAffiliationUrl'] as String? ?? '';
    final isVerified = startup['isVerified'] == true;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.orange.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue,
                  backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                      ? NetworkImage(logoUrl)
                      : null,
                  child: (logoUrl == null || logoUrl.isEmpty)
                      ? Text(firstLetter,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (field.isNotEmpty)
                        Text(field,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                ),
                _badge(isVerified),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            if (description.isNotEmpty) ...[
              Text(description,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87, height: 1.4)),
              const SizedBox(height: 10),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (founderName.isNotEmpty)
                  _chip(Icons.person_outline, founderName),
                if (location.isNotEmpty)
                  _chip(Icons.location_on_outlined, location),
                if (teamSize != null)
                  _chip(Icons.group_outlined, '$teamSize people'),
                if (website.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openUrl(website),
                    child: _chip(Icons.link, website, color: Colors.blue),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Documents
            const Text('Submitted Documents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                _docButton(
                  'Business Certificate',
                  certUrl,
                  Icons.verified_outlined,
                  Colors.purple,
                ),
                const SizedBox(width: 10),
                _docButton(
                  'ALU Affiliation',
                  aluUrl,
                  Icons.school_outlined,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action button
            SizedBox(
              width: double.infinity,
              child: isVerified
                  ? OutlinedButton.icon(
                      onPressed: () => _confirmRevoke(startup),
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16, color: Colors.red),
                      label: const Text('Revoke Verification'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _setVerified(startup, true),
                      icon: const Icon(Icons.verified, size: 16),
                      label: const Text('Verify Startup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRevoke(Map<String, dynamic> startup) async {
    final name = startup['name'] as String? ?? 'this startup';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Verification'),
        content: Text('Remove verification from $name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _setVerified(startup, false);
  }

  Widget _badge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        verified ? 'Verified' : 'Pending',
        style: TextStyle(
          color: verified ? Colors.green : const Color(0xFFE65100),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color ?? Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _docButton(
      String label, String url, IconData icon, Color color) {
    final hasUrl = url.isNotEmpty;
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: hasUrl ? () => _openUrl(url) : null,
        icon: Icon(icon, size: 15, color: hasUrl ? color : Colors.grey),
        label: Text(label,
            style: TextStyle(
                fontSize: 12, color: hasUrl ? color : Colors.grey)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: hasUrl ? color : Colors.grey.shade300),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        ),
      ),
    );
  }
}
