import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../core/models/discover_event.dart';
import '../../core/services/discovery_service.dart';
import '../../core/theme/app_colors.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final DiscoveryService _discoveryService = DiscoveryService();
  ll.LatLng? _currentPosition;
  List<DiscoverEvent> _nearbyEvents = [];
  bool _isMapReady = false;
  bool _isGettingLocation = false;
  String? _locationError;
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _selectedIndex = 0;
  AnimationController? _mapAnimationController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _mapAnimationController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        setState(() {
          _isGettingLocation = false;
          _locationError = 'Location services disabled';
        });
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          setState(() {
            _isGettingLocation = false;
            _locationError = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permission permanently denied. Please enable in settings.'),
            ),
          );
        }
        setState(() {
          _isGettingLocation = false;
          _locationError = 'Location permission permanently denied';
        });
        return;
      }

      // Get position with timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            throw Exception('Location timeout');
          },
        );
      } catch (_) {
        // Fallback to last known position if a fresh GPS fix is slow
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Unable to detect your location right now. Showing default area.'),
            ),
          );
        }
        setState(() {
          _isGettingLocation = false;
          _locationError = 'Unable to get current or last known location';
        });
        return;
      }

      final events = await _discoveryService.fetchNearbyPlaces(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _currentPosition = ll.LatLng(position!.latitude, position.longitude);
          _nearbyEvents = events;
          _isGettingLocation = false;
          _locationError = null;
        });

        if (_isMapReady && _currentPosition != null) {
          _animatedMapMove(_currentPosition!, 14.0);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _locationError = 'Something went wrong while fetching location';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Unable to get location. Please check GPS / internet and try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentPosition ?? const ll.LatLng(40.7128, -74.0060),
              initialZoom: 14.0,
              onMapReady: () {
                _isMapReady = true;
                if (_currentPosition != null) {
                  _mapController.move(_currentPosition!, 14.0);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.eventbooking',
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          if (_isGettingLocation)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          if (_locationError != null && !_isGettingLocation)
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationError!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _determinePosition,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _buildTopBar(context),
          _buildEventCarousel(),
        ],
      ),
    );
  }

  void _animatedMapMove(ll.LatLng destLocation, double destZoom) {
    _mapAnimationController?.dispose();

    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _mapAnimationController = controller;

    final animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          ll.LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (_mapAnimationController == controller) {
          _mapAnimationController = null;
        }
        controller.dispose();
      }
    });

    controller.forward();
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search camera services on map...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _selectedIndex = 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              await _determinePosition();
            },
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCarousel() {
    final filtered = _getFilteredEvents();
    if (filtered.isEmpty) {
      // When user typed something but nothing matches, show a small "not found" message
      if (_searchQuery.trim().isEmpty) return const SizedBox.shrink();

      return Positioned(
        bottom: 24,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              "No services found for \"${_searchQuery.trim()}\"",
              style: const TextStyle(
                color: AppColors.grey2,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 140,
        child: PageView.builder(
          controller: _pageController,
          itemCount: filtered.length,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
            final event = filtered[index];
            _animatedMapMove(ll.LatLng(event.latitude, event.longitude), 15.0);
          },
          itemBuilder: (context, index) {
            final event = filtered[index];
            return AnimatedScale(
              scale: _selectedIndex == index ? 1.0 : 0.9,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/event-detail',
                    arguments: event,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(event.category),
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event.category,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: AppColors.grey2,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: const TextStyle(
                                      color: AppColors.grey2,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.grey1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('CAMERA SHOP')) return Icons.camera;
    if (category.contains('STUDIO')) return Icons.mic_external_on;
    if (category.contains('EQUIPMENT')) return Icons.camera_roll;
    if (category.contains('RENTAL')) return Icons.camera_roll;
    if (category.contains('PHOTO')) return Icons.camera_alt;
    return Icons.store_mall_directory;
  }

  /// Returns events filtered only by the current search query.
  List<DiscoverEvent> _getFilteredEvents() {
    if (_nearbyEvents.isEmpty) return const [];

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      // No search text: show all nearby events (original behavior)
      return List<DiscoverEvent>.from(_nearbyEvents);
    }

    // Filter by title or location matching the query
    return _nearbyEvents
        .where(
          (e) =>
              e.title.toLowerCase().contains(query) ||
              e.location.toLowerCase().contains(query),
        )
        .toList();
  }

  /// Build markers using filtered events so map reflects search and category selection.
  List<Marker> _buildMarkers() {
    final events = _getFilteredEvents();

    final markers = <Marker>[];

    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: _currentPosition!,
          width: 30,
          height: 30,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 24,
          ),
        ),
      );
    }

    for (var i = 0; i < events.length; i++) {
      final event = events[i];
      final isSelected = _selectedIndex == i;

      markers.add(
        Marker(
          point: ll.LatLng(event.latitude, event.longitude),
          width: isSelected ? 50 : 40,
          height: isSelected ? 50 : 40,
          child: GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.location_on,
                color: isSelected ? Colors.red : AppColors.primary,
                size: isSelected ? 50 : 40,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
