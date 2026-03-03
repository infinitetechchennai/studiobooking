// lib/core/providers/filtered_vendor_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vendor.dart';
import '../../core/providers/session_provider.dart';
import '../../core/providers/vendor_content_provider.dart';

/// Returns the same stream as `vendorProvider`, but – when the logged‑in
/// user is a vendor – limits the list to the document whose id equals the
/// user uid.  Clients still get the full list.
final filteredVendorProvider = Provider.autoDispose
    .family<AsyncValue<List<Vendor>>, String>((ref, bucketFilter) {
  // 1️⃣ Get the raw stream from the original provider
  final raw = ref.watch(vendorProvider(bucketFilter));

  // 2️⃣ Grab the current session once (it’s cheap, it’s a Provider)
  final session = ref.watch(sessionProvider);

  // 3️⃣ If the logged in user is a Vendor, keep only his own document.
  //    Otherwise return the whole list.
  return raw.whenData((list) {
    if (session.user?.role == 'Vendor' && session.user?.id != null) {
      return list.where((v) => v.uid == session.user!.id).toList();
    }
    return list;
  });
});
