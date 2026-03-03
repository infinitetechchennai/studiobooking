import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/models/discover_event.dart';
import '../../core/theme/app_colors.dart';

class EventDetailScreen extends StatelessWidget {
  final DiscoverEvent? event;
  const EventDetailScreen({super.key, this.event});

  @override
  Widget build(BuildContext context) {
    // Get event from route arguments if not passed directly
    final DiscoverEvent displayEvent = event ??
        (ModalRoute.of(context)?.settings.arguments as DiscoverEvent?) ??
        DiscoverEvent(
          id: 'default',
          title: 'International Band Music Concert',
          location: '36 Guild Street London, UK',
          category: 'MUSIC',
          latitude: 0,
          longitude: 0,
          description:
              'Enjoy an international music experience with top artists.',
        );
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayEvent.title,
                        style: const TextStyle(
                          color: AppColors.grey2,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      displayEvent.isCreator
                          ? _buildInfoRow(
                              Icons.currency_rupee,
                              'Price Per Reel',
                              '₹ ${displayEvent.pricePerHour.toStringAsFixed(0)}',
                            )
                          : _buildInfoRow(
                              Icons.calendar_today,
                              displayEvent.eventDate != null
                                  ? displayEvent.eventDate
                                      .toString()
                                      .split(' ')
                                      .first
                                  : 'SLOTS',
                              '${displayEvent.bookedSlots}/${displayEvent.totalSlots} slots booked',
                            ),

                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.location_on,
                        displayEvent.category,
                        displayEvent.location,
                      ),
                      const SizedBox(height: 24),
                      _buildOrganizer(displayEvent),
                      const SizedBox(height: 24),
                      Text(
                        displayEvent.isCreator
                            ? 'About Creator'
                            : 'About Event',
                        style: const TextStyle(
                          color: AppColors.grey2,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (displayEvent.isCreator &&
                          displayEvent.instagram != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildInfoRow(
                            Icons.link,
                            'Instagram',
                            displayEvent.instagram!,
                          ),
                        ),

                      const SizedBox(height: 8),
                      Text(
                        displayEvent.description ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.grey2,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(context, displayEvent),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl:
              'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=800&q=80',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: AppColors.grey2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.grey2, fontSize: 13),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOrganizer(DiscoverEvent event) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=123'),
        ),
        const SizedBox(width: 16),
        Expanded(
          // 🔥 important to avoid overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.organizerName ??
                    (event.isCreator ? 'Reels Creator' : 'Venue Host'),
                style: const TextStyle(
                  color: AppColors.grey2,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                event.organizerRole ??
                    (event.isCreator
                        ? 'Content Creator'
                        : 'Professional Vendor'),
                style: const TextStyle(
                  color: AppColors.grey2,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withAlpha(26),
            foregroundColor: AppColors.primary,
            elevation: 0,
            minimumSize: const Size(60, 32),
          ),
          child: Text(event.isCreator ? 'Hire' : 'Follow'),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, DiscoverEvent displayEvent) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (displayEvent.isCreator) {
                    Navigator.pushNamed(
                      context,
                      '/seat-selection',
                      arguments: displayEvent,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/seat-selection',
                      arguments: displayEvent,
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(displayEvent.isCreator ? 'BOOK CREATOR' : 'BOOK SLOT'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
