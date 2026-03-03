import 'discover_event.dart';

class CreatorListing {
  final String id;
  final String ownerUserId;

  /// studio | cameraman | rental | shop
  final String type;

  final String title;
  final String description;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final double pricePerHour;
  final List<String> images;
  final bool isActive;
  final DateTime createdAt;
  final String? instagram; // <-- NEW
  const CreatorListing({
    required this.id,
    required this.ownerUserId,
    required this.type,
    required this.title,
    required this.description,
    required this.locationText,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.images,
    required this.isActive,
    required this.createdAt,
    this.instagram, // <-- NEW
  });

  CreatorListing copyWith({
    String? id,
    String? ownerUserId,
    String? type,
    String? title,
    String? description,
    String? locationText,
    double? latitude,
    double? longitude,
    double? pricePerHour,
    List<String>? images,
    bool? isActive,
    DateTime? createdAt,
    String? instagram, // <-- NEW
  }) {
    return CreatorListing(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      locationText: locationText ?? this.locationText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      instagram: instagram ?? this.instagram, // <-- NEW
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerUserId': ownerUserId,
        'type': type,
        'title': title,
        'description': description,
        'locationText': locationText,
        'latitude': latitude,
        'longitude': longitude,
        'pricePerHour': pricePerHour,
        'images': images,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'instagram': instagram, // <-- NEW
      };

  static CreatorListing fromJson(Map<String, dynamic> json) {
    double? _toDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return CreatorListing(
      id: (json['id'] ?? '').toString(),
      ownerUserId: (json['ownerUserId'] ?? '').toString(),
      type: (json['type'] ?? 'studio').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      locationText: (json['locationText'] ?? '').toString(),
      latitude: _toDoubleOrNull(json['latitude']),
      longitude: _toDoubleOrNull(json['longitude']),
      pricePerHour: (json['pricePerHour'] is num)
          ? (json['pricePerHour'] as num).toDouble()
          : double.tryParse((json['pricePerHour'] ?? '50').toString()) ?? 50.0,
      images: (json['images'] is List)
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : const [],
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      instagram: (json['instagram'] as String?), // <-- NEW
    );
  }

  /// Adapter so we can reuse existing booking/detail screens.
  DiscoverEvent toDiscoverEvent() {
    final upperType = type.toUpperCase();
    String category;
    switch (upperType) {
      case 'RENTAL':
        category = 'EQUIPMENT RENTAL';
        break;
      case 'SHOP':
        category = 'CAMERA SHOP';
        break;
      case 'STUDIO':
      default:
        category = 'STUDIO';
        break;
    }

    return DiscoverEvent(
      id: id,
      title: title,
      location: locationText,
      category: category,
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      description: description,
      pricePerHour: pricePerHour,
      isCreator: true,
      ownerId: ownerUserId,
      instagram: instagram, // <-- NEW
    );
  }
}
