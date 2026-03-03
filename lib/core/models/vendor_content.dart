// lib/core/models/vendor_content.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A single piece of vendor data (studio item, shop product, rate, staff …)
@immutable
class VendorContent {
  final String id;
  final String title;
  final String? subtitle; // This will be used for the nested category
  final String? price;
  final String type;
  final String vendorUid;
  final DateTime createdAt;

  const VendorContent({
    required this.id,
    required this.title,
    this.subtitle,
    this.price,
    required this.type,
    required this.vendorUid,
    required this.createdAt,
  });

  factory VendorContent.fromArrayItem({
    required String vendorUid,
    required String type,
    required int index,
    required Map<String, dynamic> raw,
    required Timestamp createdAt,
  }) {
    String title = '';
    String? subtitle; // This will hold the category when type is 'studio'
    String? price;

    switch (type) {
      case 'studio':
        // Use 'category' as subtitle for studio type
        title = raw['title']?.toString() ?? '';
        subtitle = raw['category']?.toString();
        break;
      case 'shop':
        title = raw['name']?.toString() ?? '';
        price = raw['price']?.toString();
        break;
      case 'rate':
        title = raw['service']?.toString() ?? '';
        price = raw['price']?.toString();
        break;
      case 'staff':
        title = raw['name']?.toString() ?? '';
        subtitle = raw['role']?.toString();
        break;
      case 'schedule':
        title = raw['title']?.toString() ??
            raw['description']?.toString() ??
            'Schedule';
        subtitle = raw['date']?.toString() ?? raw['time']?.toString();
        break;
      default:
        title = raw['title']?.toString() ??
            raw['name']?.toString() ??
            raw['service']?.toString() ??
            'Item';
        subtitle = raw['desc']?.toString() ?? raw['category']?.toString();
    }

    return VendorContent(
      id: '${vendorUid}_${type}_$index',
      title: title,
      subtitle: subtitle, // Assign captured category to subtitle
      price: price,
      type: type,
      vendorUid: vendorUid,
      createdAt: createdAt.toDate(),
    );
  }

  @override
  String toString() =>
      'VendorContent(id: $id, title: $title, subtitle: $subtitle, type: $type, vendor: $vendorUid)';
}
