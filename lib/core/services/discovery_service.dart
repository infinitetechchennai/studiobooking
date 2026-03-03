import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/discover_event.dart';

class DiscoveryService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _cacheKey = 'cached_venues';
  static const String _cacheLocationKey = 'cached_location';
  static const Duration _cacheExpiry = Duration(hours: 6);
  DateTime? _lastFetch;

  Future<List<DiscoverEvent>> fetchNearbyPlaces(double lat, double lng,
      {int radius = 10000}) async {
    // Check cache first
    if (_lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(minutes: 10)) {
      final cachedData = await _getCachedData(lat, lng);
      if (cachedData != null) {
        return cachedData;
      }
    }
    _lastFetch = DateTime.now();

    // Searching for Studios, Camera Shops, Rentals, and Photographers
    // Default radius increased to 10km (10000m) for better reliability as requested
    final String query = '''
[out:json][timeout:90];
(
  node(around:$radius, $lat, $lng)["shop"~"camera|photo"];
  node(around:$radius, $lat, $lng)["amenity"="studio"];
  node(around:$radius, $lat, $lng)["craft"="photographer"];
  node(around:$radius, $lat, $lng)["office"="photographer"];
  node(around:$radius, $lat, $lng)["shop"="electronics"];
);
out body 50;
''';

    try {
      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: {'data': query},
        headers: {
          'User-Agent': 'EventraApp/1.0 (flutter_app)',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];

        final events = elements.map((e) {
          final tags = e['tags'] ?? {};
          final name = tags['name'] ?? 'Unnamed Venue';

          // Determine specific category and price
          String category = 'STUDIO';
          double price = 50.0;

          if (tags['shop'] != null &&
              (tags['shop'].contains('camera') ||
                  tags['shop'].contains('photo'))) {
            category = 'CAMERA SHOP';
            price = 25.0 + Random().nextInt(25); // $25 - $50
          } else if (tags['shop'] == 'electronics') {
            category = 'EQUIPMENT RENTAL';
            price = 75.0 + Random().nextInt(75); // $75 - $150
          } else if (tags['amenity'] == 'studio' ||
              tags['office'] == 'studio') {
            category = 'STUDIO';
            price = 50.0 + Random().nextInt(50); // $50 - $100
          } else if (tags['craft'] == 'photographer' ||
              tags['office'] == 'photographer') {}

          double flat = 0.0;
          double flng = 0.0;

          if (e['type'] == 'node') {
            flat = e['lat'];
            flng = e['lon'];
          } else if (e['center'] != null) {
            flat = e['center']['lat'];
            flng = e['center']['lon'];
          }

          return DiscoverEvent(
            id: e['id'].toString(),
            title: name,
            location: tags['addr:street'] ?? 'Nearby your location',
            category: category,
            latitude: flat,
            longitude: flng,
            description: tags['description'] ??
                'Professional ${category.toLowerCase()} available for booking and rental services.',
            pricePerHour: price,
          );
        }).toList();

        // Cache the results
        await _cacheData(lat, lng, events);
        return events;
      }
    } catch (e) {
      // Return cached data if available, even if expired
      final oldCache = await _getAnyCachedData();
      if (oldCache != null) return oldCache;
    }
    return [];
  }

  Future<List<DiscoverEvent>?> _getCachedData(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final cachedLocation = prefs.getString(_cacheLocationKey);
      final cacheTime = prefs.getInt('cache_time');

      if (cachedJson == null || cachedLocation == null || cacheTime == null) {
        return null;
      }

      // Check if cache is expired
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTime;
      if (cacheAge > _cacheExpiry.inMilliseconds) {
        return null;
      }

      // Check if location is similar (within ~500m)
      final cachedCoords = cachedLocation.split(',');
      final cachedLat = double.parse(cachedCoords[0]);
      final cachedLng = double.parse(cachedCoords[1]);

      final distance = _calculateDistance(lat, lng, cachedLat, cachedLng);
      if (distance > 0.5) {
        return null;
      }

      final List<dynamic> jsonList = json.decode(cachedJson);
      return jsonList
          .map(
            (e) => DiscoverEvent(
              id: e['id'],
              title: e['title'],
              location: e['location'],
              category: e['category'],
              latitude: e['latitude'],
              longitude: e['longitude'],
              description: e['description'],
              pricePerHour: (e['pricePerHour'] ?? 50.0).toDouble(),
              isCreator: false, // explicit (optional)
            ),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<List<DiscoverEvent>?> _getAnyCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson == null) return null;

      final List<dynamic> jsonList = json.decode(cachedJson);
      return jsonList
          .map(
            (e) => DiscoverEvent(
              id: e['id'],
              title: e['title'],
              location: e['location'],
              category: e['category'],
              latitude: e['latitude'],
              longitude: e['longitude'],
              description: e['description'],
              pricePerHour: (e['pricePerHour'] ?? 50.0).toDouble(),
            ),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheData(
    double lat,
    double lng,
    List<DiscoverEvent> events,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = events
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'location': e.location,
              'category': e.category,
              'latitude': e.latitude,
              'longitude': e.longitude,
              'description': e.description,
              'pricePerHour': e.pricePerHour,
            },
          )
          .toList();

      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setString(_cacheLocationKey, '$lat,$lng');
      await prefs.setInt('cache_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Cache failed
    }
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
