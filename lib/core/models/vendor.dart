// lib/core/models/vendor.dart
import 'package:flutter/foundation.dart';

import 'discover_event.dart';
import 'vendor_content.dart';

@immutable
class Vendor {
  final String uid; // document id (vendor UID)
  final DateTime createdAt; // parent‑doc timestamp

  final Map<String, List<VendorContent>>
      bucketItems; // e.g. {'studio':[...], 'shop':[...]}

  const Vendor({
    required this.uid,
    required this.createdAt,
    required this.bucketItems,
  });

  /// Handy shortcut when you need a flat list (e.g. a “All” view)
  List<VendorContent> get allItems =>
      bucketItems.values.expand((e) => e).toList();

  /// Adapter to represent the entire Vendor as a single DiscoverEvent
  DiscoverEvent toDiscoverEvent() {
    // 🔥 1. Extract Staff Organizer
    String? organizerName;
    String? organizerRole;
    if (bucketItems.containsKey('staff') && bucketItems['staff']!.isNotEmpty) {
      organizerName = bucketItems['staff']!.first.title;
      organizerRole = bucketItems['staff']!.first.subtitle;
    }
    // 1. Aggregate Categories
    final Set<String> categories = {};
    for (final bucket in bucketItems.keys) {
      if (bucket == 'studio') {
        for (final item in bucketItems['studio']!) {
          if (item.subtitle != null) {
            categories.add(item.subtitle!.toUpperCase());
          } else {
            categories.add('STUDIO');
          }
        }
      } else if (bucket == 'shop') {
        categories.add('CAMERA SHOP');
      } else if (bucket == 'rate') {
        categories.add('CREATOR SERVICE');
      }
    }

    // 2. Determine Title (Use name from first item if available, or placeholder)
    String title = "Vendor ${uid.substring(0, 4)}";
    if (allItems.isNotEmpty) {
      title = allItems.first.title;
    }

    // 3. Aggregate Categories string
    final categoryLabel =
        categories.isEmpty ? 'VENDOR' : categories.join(' | ');

    // 4️⃣ Extract both prices separately
    double? studioPrice;
    double? rentalPrice;

// Studio = rate bucket
    if (bucketItems.containsKey('rate') && bucketItems['rate']!.isNotEmpty) {
      studioPrice = double.tryParse(bucketItems['rate']!.first.price ?? '0');
    }

// Rental = shop bucket
    if (bucketItems.containsKey('shop') && bucketItems['shop']!.isNotEmpty) {
      rentalPrice = double.tryParse(bucketItems['shop']!.first.price ?? '0');
    }

// Fallback for legacy UI (if needed)
    final fallbackPrice = studioPrice ?? rentalPrice ?? 0.0;

    return DiscoverEvent(
      id: uid,
      title: title,
      location: 'Storefront',
      category: categoryLabel,
      latitude: 0,
      longitude: 0,
      description: 'Professional services and equipment available.',
      studioPrice: studioPrice, // ✅ NEW
      rentalPrice: rentalPrice, // ✅ NEW
      pricePerHour: fallbackPrice,
      ownerId: uid,
      isCreator: false,
      organizerName: organizerName,
      organizerRole: organizerRole,
    );
  }
}
