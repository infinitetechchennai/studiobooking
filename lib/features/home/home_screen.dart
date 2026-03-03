import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/models/discover_event.dart';
import '../../core/models/vendor.dart';
import '../../core/providers/Creator_listings_provider.dart';
import '../../core/providers/session_provider.dart';
import '../../core/providers/vendorprovider.dart';
import '../../core/services/discovery_service.dart';
import '../../core/theme/app_colors.dart';
import 'event_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  List<DiscoverEvent> _discoveredEvents = []; // from Overpass
  bool _isLoading = true;
  String _currentCity = 'Fetching location...';
  String? _locationError;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentCity = 'Location Disabled';
            _locationError = 'Location services disabled';
          });
        }
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _currentCity = 'Permission Denied';
              _locationError = 'Location permission denied';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentCity = 'Permission Denied';
            _locationError =
                'Location permission permanently denied. Enable in settings.';
          });
        }
        return;
      }

      // Get position with timeout, with fallback to last known
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
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentCity = 'Location Error';
            _locationError =
                'Unable to get current or last known location. Tap Retry.';
          });
        }
        return;
      }
      final events = await _discoveryService.fetchNearbyPlaces(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _discoveredEvents = events;
          _isLoading = false;
          _currentCity = 'Nearby You';
          _locationError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentCity = 'Location Error';
          _locationError =
              'Something went wrong while fetching location. Tap Retry.';
        });
      }
    }
  }

  String _bucketFromCategory(String cat) {
    // We'll fetch 'All' and filter items in the UI to ensure
    // relevant items from all buckets (e.g. EQUIPMENT in studio bucket) are seen.
    return 'All';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    // 🔒 Guard: Creators should not access Home
    if (session.user?.role == 'Creator') {
      return const Scaffold(
        body: Center(
          child: Text('Creator cannot browse services'),
        ),
      );
    }
    final vendorAsync = ref.watch(
      filteredVendorProvider(_bucketFromCategory(_selectedCategory)),
    );
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(context),
                        if (_locationError != null) ...[
                          const SizedBox(height: 8),
                          _buildLocationErrorBanner(),
                        ],
                        const SizedBox(height: 24),
                        _buildCategories(),
                        const SizedBox(height: 24),
                        _buildInviteBanner(),
                        const SizedBox(height: 24),
                        _buildNearbyEvents(ref, vendorAsync),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          'Camera Services Near You',
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventListScreen(
                                  events: _allEvents(ref),
                                  title: 'All Camera Services',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildNearbyEvents(ref, vendorAsync),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      toolbarHeight: 72, // 👈 compact height
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _loadRealData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Location',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.refresh, size: 14, color: Colors.white),
                    ],
                  ),
                  Text(
                    _currentCity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search camera services...',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              fillColor: AppColors.white,
              filled: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/filter'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _locationError ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _loadRealData,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildCategories() {
    final categories = [
      {
        'name': 'Studios',
        'icon': Icons.mic_external_on,
        'color': Colors.purple
      },
      {
        'name': 'Cameramen',
        'icon': Icons.photo_camera_front,
        'color': Colors.orange
      },
      {'name': 'Rentals', 'icon': Icons.camera_roll, 'color': Colors.green},
      {'name': 'All', 'icon': Icons.category, 'color': Colors.blue},
    ];

    Widget buildItem(Map item) {
      final name = item['name'] as String;
      final color = item['color'] as Color;
      final isSelected = _selectedCategory == name;

      return GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = name);
        },
        child: Container(
          height: 90,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item['icon'],
                size: 28,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 360, // 🔥 prevents expansion on big screens
        ),
        child: Table(
          children: [
            TableRow(
              children: [
                buildItem(categories[0]),
                buildItem(categories[1]),
              ],
            ),
            TableRow(
              children: [
                buildItem(categories[2]),
                buildItem(categories[3]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: AppColors.grey2,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Row(
            children: [
              Text('See All', style: TextStyle(color: AppColors.grey2)),
              Icon(Icons.arrow_right, color: AppColors.grey2),
            ],
          ),
        ),
      ],
    );
  }

  List<DiscoverEvent> _getCreatorEvents(WidgetRef ref) {
    final listings = ref.watch(activeCreatorListingsProvider);
    return listings.map((l) => l.toDiscoverEvent()).toList();
  }

  List<DiscoverEvent> _allEvents(WidgetRef ref) {
    return [
      ..._discoveredEvents,
      ..._getCreatorEvents(ref),
    ];
  }

  Widget _buildNearbyEvents(
      WidgetRef ref, AsyncValue<List<Vendor>> asyncVendors) {
    return asyncVendors.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Text('Error loading vendors'),
      data: (vendors) {
        final allEvents = _allEvents(ref);
        final List<DiscoverEvent> unifiedList = [...allEvents];

        // Add each vendor document as a single DiscoverEvent card
        for (final vendor in vendors) {
          unifiedList.add(vendor.toDiscoverEvent());
        }

        if (unifiedList.isEmpty) {
          return const Text(
            'No camera services found near you.',
            style: TextStyle(color: AppColors.grey2, fontSize: 13),
          );
        }

        Iterable<DiscoverEvent> filtered = unifiedList;

        // Apply Category Filtering
        switch (_selectedCategory) {
          case 'Studios':
            filtered = filtered
                .where((e) => e.category.toUpperCase().contains('STUDIO'));
            break;
          case 'Rentals':
            filtered = filtered.where(
              (e) =>
                  e.category.toUpperCase().contains('RENTAL') ||
                  e.category.toUpperCase().contains('EQUIPMENT'),
            );
            break;
          case 'Cameramen':
            filtered = filtered.where((e) =>
                e.category.toUpperCase().contains('CAMERAMAN') ||
                e.category.toUpperCase().contains('CREATOR SERVICE') ||
                e.category.toUpperCase().contains('PHOTOGRAPHER'));
            break;
        }

        // Apply Search Filtering
        final query = _searchQuery.trim().toLowerCase();
        if (query.isNotEmpty) {
          filtered = filtered.where(
            (e) =>
                e.title.toLowerCase().contains(query) ||
                e.location.toLowerCase().contains(query) ||
                e.category.toLowerCase().contains(query),
          );
        }

        final result = filtered.toList()
          ..sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return NearbyEventTile(event: result[index]);
          },
        );
      },
    );
  }

  Widget _buildInviteBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invite your friends',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  r'Get $20 for every friend you invite',
                  style: TextStyle(color: AppColors.grey2, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 36),
                    backgroundColor: Colors.cyan,
                  ),
                  child: const Text(
                    'INVITE',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            width: 80,
          ), // Use logo as placeholder for illustration
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final DiscoverEvent event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final container = ProviderScope.containerOf(context);
        final session = container.read(sessionProvider);

        if (session.user?.role != 'client') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only clients can book services')),
          );
          return;
        }

        Navigator.pushNamed(
          context,
          '/event-detail',
          arguments: event,
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=500&q=80',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.grey2,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NearbyEventTile extends StatelessWidget {
  final DiscoverEvent event;
  const NearbyEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/event-detail',
          arguments: event,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: AppColors.primary.withAlpha(26),
                height: 80,
                width: 80,
                child: Icon(
                  _getCategoryIcon(event.category),
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.grey2,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('CAMERA SHOP')) return Icons.camera;
    if (category.contains('CAMERA STUDIO')) return Icons.mic_external_on;
    if (category.contains('CAMERA EQUIPMENT')) return Icons.camera_roll;
    if (category.contains('CAMERA RENTAL')) return Icons.camera_roll;
    if (category.contains('PHOTOGRAPGHER')) return Icons.camera_alt;
    return Icons.store_mall_directory;
  }
}
