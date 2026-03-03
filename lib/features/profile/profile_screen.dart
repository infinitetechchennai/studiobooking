import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = session.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 👈 removes back arrow
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name,
                style: const TextStyle(
                    color: AppColors.grey2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user.email, style: const TextStyle(color: AppColors.grey2)),
            const SizedBox(height: 8),
            Text(
              user.role.toUpperCase(),
              style: const TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            _item(Icons.person_outline, 'Personal Information', AppColors.grey1,
                () {
              // TODO: Navigate to personal info screen
            }),
            _item(Icons.notifications_none, 'Notifications', AppColors.grey1,
                () {
              // TODO
            }),
            _item(Icons.payment_outlined, 'Payment Methods', AppColors.grey1,
                () {
              // TODO
            }),
            _item(Icons.favorite_border, 'Interests', AppColors.grey1, () {
              // TODO
            }),
            _item(Icons.help_outline, 'Help & Support', AppColors.grey1, () {
              // TODO
            }),
            _item(Icons.logout, 'Log Out', Colors.red, () async {
              await ref.read(sessionProvider.notifier).signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey3),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: color)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
