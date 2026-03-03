// lib/core/providers/vendor_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vendor.dart';
import '../../core/models/vendor_content.dart';

/// family‑provider → bucket name (studio, shop, rate, staff, schedule, or 'All')
final vendorProvider = StreamProvider.autoDispose
    .family<List<Vendor>, String>((ref, bucketFilter) {
  final firestore = FirebaseFirestore.instance;
  final coll = firestore.collection('vendor_content');

  return coll.snapshots().map((snapshot) {
    final List<Vendor> vendors = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // --------------------------------------------------------------
      // 1️⃣  Parent‑document timestamp (used for sorting)
      // --------------------------------------------------------------
      final rawCreated = data['createdAt'];
      Timestamp ts;
      if (rawCreated is Timestamp) {
        ts = rawCreated;
      } else if (rawCreated is int) {
        ts = Timestamp.fromMillisecondsSinceEpoch(rawCreated);
      } else {
        ts = Timestamp.fromMillisecondsSinceEpoch(0);
      }

      // --------------------------------------------------------------
      // 2️⃣  Build bucket → List<VendorContent>
      // --------------------------------------------------------------
      const allBuckets = [
        'studio',
        'shop',
        'rate',
        'staff',
        'schedule',
      ];
      final Map<String, List<VendorContent>> bucketMap = {};

      for (final bucket in allBuckets) {
        final List rawArray = (data[bucket] as List?) ?? [];

        final items = rawArray
            .asMap()
            .entries
            .map(
              (e) => VendorContent.fromArrayItem(
                vendorUid: doc.id,
                type: bucket,
                index: e.key,
                raw: Map<String, dynamic>.from(e.value as Map),
                createdAt: ts,
              ),
            )
            .toList();

        if (items.isNotEmpty) bucketMap[bucket] = items;
      }

      // --------------------------------------------------------------
      // 3️⃣  Apply the optional bucket filter (used by the UI tabs)
      // --------------------------------------------------------------
      if (bucketFilter != 'All') {
        if (!bucketMap.containsKey(bucketFilter)) {
          // This vendor does NOT have the requested bucket → skip it.
          continue;
        }
        // Keep only the requested bucket, discard the others.
        bucketMap.removeWhere((k, _) => k != bucketFilter);
      }

      vendors.add(Vendor(
        uid: doc.id,
        createdAt: ts.toDate(),
        bucketItems: bucketMap,
      ));
    }

    // newest vendor first
    vendors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return vendors;
  });
});
