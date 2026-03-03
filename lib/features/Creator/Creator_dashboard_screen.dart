import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/Creator_listings_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';
import 'edit_listing_screen.dart';

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final myListings = ref.watch(myCreatorListingsProvider);

    if (!session.isLoading && session.user?.role.toLowerCase() != 'creator') {
      return const Scaffold(
        body: Center(
          child: Text('Only Creators can access this page'),
        ),
      );
    }

    if (session.user?.isSuspended == true) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(session.user!.suspendedUntil!);
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Creator Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: session.user == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditReelsCreatorScreen(),
                  ),
                );
              },
        label: const Text('Add Listing'),
        icon: const Icon(Icons.add),
      ),
      body: session.isLoading
          ? const Center(child: CircularProgressIndicator())
          : session.user == null
              ? const Center(
                  child: Text('Please sign in to manage listings.'),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${session.user!.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.grey2),
                              ),
                              const Text(
                                'Enhance yourself in workshop',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.grey2),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Align(
                                // Added Align to keep the button to the right
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final url = Uri.parse(
                                        'https://meet.google.com/workshop-dummy');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  },
                                  icon: const Icon(Icons.video_call),
                                  label: const Text('JOIN WORKSHOP'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Listings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.grey2),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height:
                            200, // Slightly reduced height to fit global button
                        child: myListings.isEmpty
                            ? const Center(
                                child: Text(
                                  'No listings yet. Tap “Add Listing”.',
                                  style: TextStyle(color: AppColors.grey2),
                                ),
                              )
                            : ListView.separated(
                                itemCount: myListings.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final listing = myListings[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _typeIcon(listing.type),
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                listing.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${listing.type.toUpperCase()} • ₹${listing.pricePerHour.toStringAsFixed(0)}/hr',
                                                style: const TextStyle(
                                                    color: AppColors.grey2,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          children: [
                                            Switch(
                                              value: listing.isActive,
                                              onChanged: (_) => ref
                                                  .read(CreatorListingsProvider
                                                      .notifier)
                                                  .toggleActive(listing.id),
                                              thumbColor:
                                                  const WidgetStatePropertyAll(
                                                      AppColors.primary),
                                              trackColor:
                                                  WidgetStatePropertyAll(
                                                      AppColors.primary
                                                          .withAlpha(128)),
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (v) async {
                                            if (v == 'edit') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditReelsCreatorScreen(
                                                    existing: listing,
                                                  ),
                                                ),
                                              );
                                            } else if (v == 'delete') {
                                              await ref
                                                  .read(CreatorListingsProvider
                                                      .notifier)
                                                  .deleteById(listing.id);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'rental':
        return Icons.camera_roll;
      case 'shop':
        return Icons.store;
      case 'studio':
      default:
        return Icons.mic_external_on;
    }
  }
}
