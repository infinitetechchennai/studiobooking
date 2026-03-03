import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/booking.dart';
import '../../core/providers/bookings_provider.dart';
import '../../core/theme/app_colors.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsProvider);
    final now = DateTime.now();

    final upcoming = bookings
        .where((b) =>
            DateTime(b.date.year, b.date.month, b.date.day)
                .isAfter(DateTime(now.year, now.month, now.day)) ||
            DateTime(b.date.year, b.date.month, b.date.day)
                .isAtSameMomentAs(DateTime(now.year, now.month, now.day)))
        .toList();

    final past = bookings
        .where((b) => DateTime(b.date.year, b.date.month, b.date.day)
            .isBefore(DateTime(now.year, now.month, now.day)))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 👈 removes back arrow
          title: const Text('My Bookings',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'UPCOMING'),
              Tab(text: 'PAST'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey3,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            upcoming.isEmpty
                ? const Center(
                    child: Text('No upcoming bookings',
                        style: TextStyle(color: AppColors.grey2)),
                  )
                : _buildTicketList(context, upcoming),
            past.isEmpty
                ? const Center(
                    child: Text('No past bookings',
                        style: TextStyle(color: AppColors.grey2)),
                  )
                : _buildTicketList(context, past),
          ],
        ),
      ),
    );
  }
}

Widget _buildTicketList(BuildContext context, List<Booking> bookings) {
  return ListView.separated(
    padding: const EdgeInsets.all(24),
    itemCount: bookings.length,
    separatorBuilder: (_, index) => const SizedBox(height: 16),
    itemBuilder: (context, index) {
      final booking = bookings[index];
      return _TicketTile(booking: booking);
    },
  );
}

class _TicketTile extends StatelessWidget {
  final Booking booking;

  const _TicketTile({
    required this.booking,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(booking.date);
    final timeStr = booking.timeSlot;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/ticket-detail',
        arguments: booking,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.event_available, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr • $timeStr',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.grey2),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.event.location,
                          style: const TextStyle(
                              color: AppColors.grey2, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.grey3),
          ],
        ),
      ),
    );
  }
}
