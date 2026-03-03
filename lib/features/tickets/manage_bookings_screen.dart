import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/booking.dart';
import '../../core/providers/Creator_listings_provider.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/theme/app_colors.dart';

class ManageBookingsScreen extends ConsumerWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);
    final myListings = ref.watch(myCreatorListingsProvider);
    final myListingIds = myListings.map((l) => l.id).toSet();

    final filteredBookings =
        bookings.where((b) => myListingIds.contains(b.event.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: filteredBookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings to manage.',
                style: TextStyle(color: AppColors.grey2),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredBookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return _BookingCard(booking: booking);
              },
            ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Booking ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                booking.id,
                style: const TextStyle(
                  color: AppColors.grey2,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// Time Slot
          Text(
            'Slot: ${booking.timeSlot}',
            style: const TextStyle(
              color: AppColors.grey2,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          /// Media Link Section
          if (booking.mediaDriveLink != null &&
              booking.mediaDriveLink!.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.link, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Drive Link Added',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showMediaLinkDialog(context, ref, booking),
                  child: const Text('EDIT'),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showMediaLinkDialog(context, ref, booking),
                icon: const Icon(Icons.add_link, size: 18),
                label: const Text('ADD DRIVE LINK'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMediaLinkDialog(
      BuildContext context, WidgetRef ref, Booking booking) {
    final controller =
        TextEditingController(text: booking.mediaDriveLink ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Media Drive Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the Google Drive link for photos/videos.',
              style: TextStyle(fontSize: 12, color: AppColors.grey2),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://drive.google.com/...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(bookingsProvider.notifier)
                  .updateBookingMediaLink(booking.id, controller.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
