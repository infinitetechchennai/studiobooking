import 'package:eventbooking/features/profile/profile_screen.dart';
import 'package:eventbooking/features/tickets/my_tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../Creator/Creator_dashboard_screen.dart';
import '../explore/explore_map_screen.dart';
import '../tickets/manage_bookings_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['index'] is int) {
        _selectedIndex = args['index'];
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final user = session.user;

    // Global Suspension Check
    if (user?.isSuspended == true) {
      final date = DateTime.fromMillisecondsSinceEpoch(user!.suspendedUntil!);
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Color(0xFFF44336)),
              const SizedBox(height: 16),
              const Text(
                'Account Suspended',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your account is suspended until\n${date.day}/${date.month}/${date.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey2),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(sessionProvider.notifier).signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }
    // Case-insensitive role check to handle both "creator" and "Creator"
    final isCreator = user?.role.toLowerCase() == 'creator';
    // ✅ RESET index when role changes
    if (isCreator && _selectedIndex > 3) {
      _selectedIndex = 0;
    }
    if (!isCreator && _selectedIndex > 3) {
      _selectedIndex = 0;
    }
    final screens = isCreator
        ? const [
            CreatorDashboardScreen(),
            ExploreMapScreen(),
            ManageBookingsScreen(),
            ProfileScreen(),
          ]
        : const [
            HomeScreen(),
            ExploreMapScreen(),
            MyTicketsScreen(),
            ProfileScreen(),
          ];

    // Determine the number of items based on the role
    final navigationItems = isCreator
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              label: 'Creator',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              label: 'Manage',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    // Ensure _selectedIndex is within bounds before passing to BottomNavigationBar
    int effectiveSelectedIndex = _selectedIndex;
    if (effectiveSelectedIndex >= navigationItems.length) {
      effectiveSelectedIndex =
          navigationItems.length - 1; // Default to last valid index
      if (effectiveSelectedIndex < 0) {
        effectiveSelectedIndex = 0; // Ensure it's not negative
      }
    }

    return Scaffold(
      body: IndexedStack(
        // Use the potentially adjusted index
        index: effectiveSelectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Use the potentially adjusted index
        currentIndex: effectiveSelectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Update _selectedIndex
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey3,
        showUnselectedLabels: true,
        items: navigationItems,
      ),
    );
  }
}
