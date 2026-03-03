import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/discover_event.dart';
import '../home/home_screen.dart';

class EventListScreen extends StatelessWidget {
  final List<DiscoverEvent> events;
  final String title;

  const EventListScreen({
    super.key,
    required this.events,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: events.isEmpty
          ? const Center(
              child: Text(
                'No events found nearby',
                style: TextStyle(fontSize: 16, color: AppColors.grey2),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return NearbyEventTile(event: events[index]);
              },
            ),
    );
  }
}
