import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/map_view_widget.dart';
import './widgets/region_header_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/server_list_item_widget.dart';

class ServerSelectionScreen extends StatefulWidget {
  const ServerSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ServerSelectionScreen> createState() => _ServerSelectionScreenState();
}

class _ServerSelectionScreenState extends State<ServerSelectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isMapView = false;
  String _currentServerId = '1';
  Map<String, bool> _expandedRegions = {};

  final List<Map<String, dynamic>> _mockServers = [
    {
      "id": "1",
      "city": "New York",
      "country": "United States",
      "region": "North America",
      "flagUrl": "https://flagcdn.com/w320/us.png",
      "load": "Low",
      "ping": 25,
      "capacity": 45,
      "isFavorite": true,
      "p2pSupport": true,
      "protocols": ["OpenVPN", "IKEv2", "WireGuard"],
      "latitude": 40.7128,
      "longitude": -74.0060,
    },
    {
      "id": "2",
      "city": "Los Angeles",
      "country": "United States",
      "region": "North America",
      "flagUrl": "https://flagcdn.com/w320/us.png",
      "load": "Medium",
      "ping": 35,
      "capacity": 67,
      "isFavorite": false,
      "p2pSupport": true,
      "protocols": ["OpenVPN", "IKEv2"],
      "latitude": 34.0522,
      "longitude": -118.2437,
    },
    {
      "id": "3",
      "city": "London",
      "country": "United Kingdom",
      "region": "Europe",
      "flagUrl": "https://flagcdn.com/w320/gb.png",
      "load": "Low",
      "ping": 45,
      "capacity": 32,
      "isFavorite": true,
      "p2pSupport": false,
      "protocols": ["OpenVPN", "WireGuard"],
      "latitude": 51.5074,
      "longitude": -0.1278,
    },
    {
      "id": "4",
      "city": "Frankfurt",
      "country": "Germany",
      "region": "Europe",
      "flagUrl": "https://flagcdn.com/w320/de.png",
      "load": "High",
      "ping": 55,
      "capacity": 89,
      "isFavorite": false,
      "p2pSupport": true,
      "protocols": ["OpenVPN", "IKEv2", "WireGuard"],
      "latitude": 50.1109,
      "longitude": 8.6821,
    },
    {
      "id": "5",
      "city": "Tokyo",
      "country": "Japan",
      "region": "Asia Pacific",
      "flagUrl": "https://flagcdn.com/w320/jp.png",
      "load": "Medium",
      "ping": 78,
      "capacity": 56,
      "isFavorite": true,
      "p2pSupport": false,
      "protocols": ["OpenVPN", "IKEv2"],
      "latitude": 35.6762,
      "longitude": 139.6503,
    },
    {
      "id": "6",
      "city": "Singapore",
      "country": "Singapore",
      "region": "Asia Pacific",
      "flagUrl": "https://flagcdn.com/w320/sg.png",
      "load": "Low",
      "ping": 65,
      "capacity": 41,
      "isFavorite": false,
      "p2pSupport": true,
      "protocols": ["OpenVPN", "WireGuard"],
      "latitude": 1.3521,
      "longitude": 103.8198,
    },
    {
      "id": "7",
      "city": "Sydney",
      "country": "Australia",
      "region": "Asia Pacific",
      "flagUrl": "https://flagcdn.com/w320/au.png",
      "load": "Medium",
      "ping": 95,
      "capacity": 73,
      "isFavorite": false,
      "p2pSupport": true,
      "protocols": ["OpenVPN", "IKEv2", "WireGuard"],
      "latitude": -33.8688,
      "longitude": 151.2093,
    },
    {
      "id": "8",
      "city": "Toronto",
      "country": "Canada",
      "region": "North America",
      "flagUrl": "https://flagcdn.com/w320/ca.png",
      "load": "Low",
      "ping": 42,
      "capacity": 38,
      "isFavorite": true,
      "p2pSupport": false,
      "protocols": ["OpenVPN", "WireGuard"],
      "latitude": 43.6532,
      "longitude": -79.3832,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _initializeExpandedRegions();
  }

  void _initializeExpandedRegions() {
    final regions = _getUniqueRegions();
    for (String region in regions) {
      _expandedRegions[region] = true;
    }
  }

  List<String> _getUniqueRegions() {
    return _mockServers
        .map((server) => server['region'] as String)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> _getFilteredServers() {
    List<Map<String, dynamic>> filtered = _mockServers;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((server) {
        final city = (server['city'] as String).toLowerCase();
        final country = (server['country'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return city.contains(query) || country.contains(query);
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case 'favorites':
        filtered =
            filtered.where((server) => server['isFavorite'] as bool).toList();
        break;
      case 'low_latency':
        filtered =
            filtered.where((server) => (server['ping'] as int) < 50).toList();
        break;
      case 'p2p':
        filtered =
            filtered.where((server) => server['p2pSupport'] as bool).toList();
        break;
    }

    return filtered;
  }

  Map<String, List<Map<String, dynamic>>> _groupServersByRegion() {
    final filtered = _getFilteredServers();
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var server in filtered) {
      final region = server['region'] as String;
      if (!grouped.containsKey(region)) {
        grouped[region] = [];
      }
      grouped[region]!.add(server);
    }

    return grouped;
  }

  void _toggleFavorite(String serverId) {
    setState(() {
      final serverIndex = _mockServers.indexWhere((s) => s['id'] == serverId);
      if (serverIndex != -1) {
        _mockServers[serverIndex]['isFavorite'] =
            !(_mockServers[serverIndex]['isFavorite'] as bool);
      }
    });
  }

  void _connectToServer(Map<String, dynamic> server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect to Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connecting to ${server['city']}, ${server['country']}'),
            SizedBox(height: 2.h),
            Text(
              'Estimated connection time: 3-5 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 2.h),
            const LinearProgressIndicator(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentServerId = server['id'] as String;
              });
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard-screen');
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _performSpeedTest(Map<String, dynamic> server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speed Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Testing connection speed to ${server['city']}...'),
            SizedBox(height: 2.h),
            const CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'This may take a few moments',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    // Simulate speed test
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Speed Test Results'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Server: ${server['city']}, ${server['country']}'),
                SizedBox(height: 1.h),
                Text('Download: 85.4 Mbps'),
                Text('Upload: 42.1 Mbps'),
                Text('Ping: ${server['ping']}ms'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Selection'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
            icon: CustomIconWidget(
              iconName: _isMapView ? 'list' : 'map',
              color: isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                // Refresh server data
              });
            },
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight,
              size: 6.w,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Servers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard Tab (placeholder)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'dashboard',
                  size: 20.w,
                  color: isDark
                      ? AppTheme.onSurfaceVariantDark
                      : AppTheme.onSurfaceVariantLight,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Dashboard View',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 1.h),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/dashboard-screen'),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),

          // Servers Tab
          _isMapView ? _buildMapView() : _buildListView(),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final groupedServers = _groupServersByRegion();

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          // Refresh server data
        });
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),

          // Filter Chips
          FilterChipsWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),

          // Server List
          Expanded(
            child: groupedServers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 2.h),
                    itemCount: groupedServers.length * 2, // Headers + servers
                    itemBuilder: (context, index) {
                      final regionIndex = index ~/ 2;
                      final isHeader = index % 2 == 0;
                      final regions = groupedServers.keys.toList();

                      if (regionIndex >= regions.length)
                        return const SizedBox.shrink();

                      final region = regions[regionIndex];
                      final servers = groupedServers[region]!;
                      final isExpanded = _expandedRegions[region] ?? true;

                      if (isHeader) {
                        return RegionHeaderWidget(
                          regionName: region,
                          serverCount: servers.length,
                          isExpanded: isExpanded,
                          onToggle: () {
                            setState(() {
                              _expandedRegions[region] = !isExpanded;
                            });
                          },
                        );
                      } else {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isExpanded ? null : 0,
                          child: isExpanded
                              ? Column(
                                  children: servers.map((server) {
                                    return ServerListItemWidget(
                                      server: server,
                                      isCurrentServer:
                                          server['id'] == _currentServerId,
                                      onTap: () => _connectToServer(server),
                                      onFavoriteToggle: () => _toggleFavorite(
                                          server['id'] as String),
                                      onConnect: () => _connectToServer(server),
                                      onSpeedTest: () =>
                                          _performSpeedTest(server),
                                    );
                                  }).toList(),
                                )
                              : const SizedBox.shrink(),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return MapViewWidget(
      servers: _getFilteredServers(),
      onServerSelected: _connectToServer,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            size: 20.w,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 2.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'No servers found for "$_searchQuery"'
                : 'No servers available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Please check your connection and try again',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'all';
              });
            },
            child: Text(_searchQuery.isNotEmpty ? 'Clear Search' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
