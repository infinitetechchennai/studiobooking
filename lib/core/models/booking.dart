import 'package:cloud_firestore/cloud_firestore.dart';

import 'discover_event.dart';

class Booking {
  final String id;
  final String clientId;
  final String? creatorId;
  final String listingId; // 🔥 NEW
  final DiscoverEvent event; // Keep for local usage
  final DateTime date;
  final String timeSlot;
  final double totalAmount;
  final double advancePaid;
  final double remainingAmount;
  final String clientType;

  final int duration;
  final String? mediaDriveLink;

  Booking({
    required this.id,
    required this.clientId,
    this.creatorId,
    required this.listingId,
    required this.event,
    required this.date,
    required this.timeSlot,
    required this.totalAmount,
    required this.advancePaid,
    required this.remainingAmount,
    required this.clientType,
    required this.duration,
    this.mediaDriveLink,
  });

  // 🔹 Local JSON (for SharedPreferences / local store)
  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'creatorId': creatorId,
        'listingId': listingId,
        'event': event.toJson(),
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'totalAmount': totalAmount,
        'advancePaid': advancePaid,
        'remainingAmount': remainingAmount,
        'clientType': clientType,
        'duration': duration,
        'mediaDriveLink': mediaDriveLink,
      };

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      creatorId: json['creatorId'] ?? '', // Add null check
      listingId: json['listingId'] ?? '', // Add null check
      event: DiscoverEvent.fromJson(json['event']),
      date: (json['date'] is Timestamp)
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      timeSlot: json['timeSlot'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      advancePaid: (json['advancePaid'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ??
              ((json['totalAmount'] as num?)?.toDouble() ?? 0))
          .toDouble(),
      clientType: json['clientType'] ?? 'individual',
      duration: json['duration'],
      mediaDriveLink: json['mediaDriveLink'],
    );
  }

  // 🔥 Firestore Map (for production)
  Map<String, dynamic> toFirestore() => {
        'clientId': clientId,
        'creatorId': creatorId,
        'listingId': listingId,
        'date': Timestamp.fromDate(date),
        'timeSlot': timeSlot,
        'totalAmount': totalAmount,
        'advancePaid': advancePaid,
        'remainingAmount': remainingAmount,
        'clientType': clientType,
        'duration': duration,
        'mediaDriveLink': mediaDriveLink,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
