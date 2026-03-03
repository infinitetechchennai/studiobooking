class DiscoverEvent {
  final String id;
  final String title;
  final String location;
  final String category;
  final double latitude;
  final double longitude;
  final String? description;
  final String? organizerName;
  final String? organizerRole;
  final double? studioPrice;
  final double? rentalPrice;

  final double pricePerHour; // for creator services
  final bool isCreator;
  final String? ownerId;
  final String? instagram; // <-- NEW FIELD
  final DateTime? eventDate; // for fixed events
  final int totalSlots;
  final int bookedSlots;

  final bool isActive;
  final List<String> images;
  final DateTime createdAt;

  DiscoverEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.description,
    this.organizerName,
    this.organizerRole,
    this.studioPrice,
    this.rentalPrice,
    this.pricePerHour = 50.0,
    this.isCreator = false,
    this.ownerId,
    this.instagram, // <-- NEW
    this.eventDate,
    this.totalSlots = 0,
    this.bookedSlots = 0,
    this.isActive = true,
    this.images = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'studioPrice': studioPrice,
        'rentalPrice': rentalPrice,
        'description': description,
        'pricePerHour': pricePerHour,
        'isCreator': isCreator,
        'ownerId': ownerId,
        'instagram': instagram, // <-- NEW
        'eventDate': eventDate?.toIso8601String(),
        'totalSlots': totalSlots,
        'bookedSlots': bookedSlots,
        'isActive': isActive,
        'images': images,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DiscoverEvent.fromJson(Map<String, dynamic> json) {
    return DiscoverEvent(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      category: json['category'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'],
      organizerName: json['organizerName'], // ✅ add
      organizerRole: json['organizerRole'], // ✅ add
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble() ?? 50.0,
      isCreator: json['isCreator'] ?? false,
      ownerId: json['ownerId'],
      studioPrice: (json['studioPrice'] as num?)?.toDouble(),
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble(),
      instagram: json['instagram'], // <-- NEW
      eventDate:
          json['eventDate'] != null ? DateTime.parse(json['eventDate']) : null,
      totalSlots: json['totalSlots'] ?? 0,
      bookedSlots: json['bookedSlots'] ?? 0,
      isActive: json['isActive'] ?? true,
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
