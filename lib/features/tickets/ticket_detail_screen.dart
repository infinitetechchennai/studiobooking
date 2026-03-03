import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/booking.dart';
import '../../core/theme/app_colors.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({super.key});

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
    final args = ModalRoute.of(context)?.settings.arguments;
    final booking = args is Booking ? args : null;

    return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          title: const Text('Booking Details',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Colors.green, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Confirmed',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    booking?.event.title ?? 'Event',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TicketInfo(
                        label: 'Date',
                        value:
                            booking != null ? _formatDate(booking.date) : '—',
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      const SizedBox(height: 16),
                      _TicketInfo(
                        label: 'Place',
                        value: booking?.event.location ?? '—',
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      const SizedBox(height: 16),
                      _TicketInfo(
                        label: 'Time',
                        value: booking?.timeSlot ?? '—',
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      const SizedBox(height: 16),
                      _TicketInfo(
                        label: 'Booking ID',
                        value: booking?.id ?? '—',
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.shadowColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.primaryLight, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please show this confirmation at the venue for entry.',
                            style: TextStyle(
                                color: AppColors.primaryLight, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (booking?.mediaDriveLink != null &&
                      booking!.mediaDriveLink!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(booking.mediaDriveLink!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        icon: const Icon(Icons.drive_file_rename_outline),
                        label: const Text('VIEW PHOTOS & VIDEOS',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement download or share
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('DOWNLOAD RECEIPT',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK TO HOME',
                        style: TextStyle(color: AppColors.grey3)),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class _TicketInfo extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  const _TicketInfo(
      {required this.label,
      required this.value,
      this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.grey2, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
