import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connect/repositories/auth_repository.dart';

class StartupProfileSheet extends StatefulWidget {
  final String name;
  final String email;

  const StartupProfileSheet({
    super.key,
    required this.name,
    required this.email,
  });

  static void show(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StartupProfileSheet(name: name, email: email),
    );
  }

  @override
  State<StartupProfileSheet> createState() => _StartupProfileSheetState();
}

class _StartupProfileSheetState extends State<StartupProfileSheet> {
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().resetPassword(widget.email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${widget.email}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout(BuildContext parentContext) async {
    final router = GoRouter.of(parentContext);
    setState(() => _isLoading = true);
    try {
      await AuthService().signOut();
      if (mounted) router.go('/role-selection');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter =
        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'S';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue,
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.email,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.blue, size: 20),
            ),
            title: const Text(
              'Update Password',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Send a reset link to your email',
              style: TextStyle(fontSize: 12),
            ),
            trailing: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _isLoading ? null : _updatePassword,
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _isLoading ? null : () => _logout(context),
          ),
        ],
      ),
    );
  }
}
