import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/additional_stats_widget.dart';
import './widgets/connection_info_widget.dart';
import './widgets/connection_metrics_widget.dart';
import './widgets/connection_status_widget.dart';
import './widgets/quick_settings_widget.dart';
import './widgets/server_rotation_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _connectionStatus = 'disconnected';
  String _currentIp = '192.168.1.100';
  String _connectionDuration = '00:00:00';
  int _rotationCountdown = 1800; // 30 minutes
  double _uploadSpeed = 2.5;
  double _downloadSpeed = 15.8;
  String _totalDataUsage = '2.4 GB';
  bool _killSwitchEnabled = true;
  bool _autoRotationEnabled = true;
  bool _notificationsEnabled = true;
  int _ping = 45;
  int _serverLoad = 35;
  String _protocol = 'OpenVPN';
  bool _showAdditionalStats = false;

  Timer? _connectionTimer;
  Timer? _rotationTimer;
  Duration _connectionTime = Duration.zero;

  final List<double> _speedHistory = [
    10.2,
    12.5,
    15.8,
    18.3,
    16.7,
    14.2,
    17.9,
    15.8
  ];

  // Mock server data
  final List<Map<String, dynamic>> _servers = [
    {
      "id": 1,
      "name": "United States - New York",
      "country": "United States",
      "city": "New York",
      "flag": "https://flagcdn.com/w320/us.png",
      "ping": 45,
      "load": 35,
    },
    {
      "id": 2,
      "name": "United Kingdom - London",
      "country": "United Kingdom",
      "city": "London",
      "flag": "https://flagcdn.com/w320/gb.png",
      "ping": 78,
      "load": 52,
    },
    {
      "id": 3,
      "name": "Germany - Frankfurt",
      "country": "Germany",
      "city": "Frankfurt",
      "flag": "https://flagcdn.com/w320/de.png",
      "ping": 65,
      "load": 28,
    },
    {
      "id": 4,
      "name": "Japan - Tokyo",
      "country": "Japan",
      "city": "Tokyo",
      "flag": "https://flagcdn.com/w320/jp.png",
      "ping": 120,
      "load": 45,
    },
  ];

  Map<String, dynamic> _currentServer = {};

  @override
  void initState() {
    super.initState();
    _currentServer = _servers.first;
    _startRotationTimer();
    _updateSpeedData();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _connectionTime = _connectionTime + const Duration(seconds: 1);
        _connectionDuration = _formatDuration(_connectionTime);
      });
    });
  }

  void _stopConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTime = Duration.zero;
    _connectionDuration = '00:00:00';
  }

  void _startRotationTimer() {
    _rotationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rotationCountdown > 0) {
        setState(() {
          _rotationCountdown--;
        });
      } else {
        _rotateServer();
        _rotationCountdown = 1800; // Reset to 30 minutes
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _toggleConnection() {
    setState(() {
      if (_connectionStatus == 'connected') {
        _connectionStatus = 'disconnected';
        _currentIp = '192.168.1.100';
        _stopConnectionTimer();
      } else {
        _connectionStatus = 'connecting';
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _connectionStatus = 'connected';
              _currentIp = '185.243.218.45';
              _startConnectionTimer();
            });
          }
        });
      }
    });
  }

  void _rotateServer() {
    if (_autoRotationEnabled && _connectionStatus == 'connected') {
      final currentIndex = _servers.indexOf(_currentServer);
      final nextIndex = (currentIndex + 1) % _servers.length;
      setState(() {
        _currentServer = _servers[nextIndex];
        _ping = (_currentServer['ping'] as int);
        _serverLoad = (_currentServer['load'] as int);
      });
    }
  }

  void _rotateNow() {
    _rotateServer();
    setState(() {
      _rotationCountdown = 1800; // Reset countdown
    });
  }

  void _updateSpeedData() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_connectionStatus == 'connected' && mounted) {
        setState(() {
          _uploadSpeed = 1.0 + (DateTime.now().millisecond % 100) / 50.0;
          _downloadSpeed = 10.0 + (DateTime.now().millisecond % 200) / 10.0;

          // Update speed history
          _speedHistory.removeAt(0);
          _speedHistory.add(_downloadSpeed);
        });
      }
    });
  }

  void _showServerSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Select Server',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                itemCount: _servers.length,
                itemBuilder: (context, index) {
                  final server = _servers[index];
                  final isSelected = server['id'] == _currentServer['id'];

                  return ListTile(
                    leading: CustomImageWidget(
                      imageUrl: server['flag'] as String,
                      width: 8.w,
                      height: 6.w,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      server['name'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      'Ping: ${server['ping']}ms • Load: ${server['load']}%',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 6.w,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _currentServer = server;
                        _ping = server['ping'] as int;
                        _serverLoad = server['load'] as int;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _emergencyDisconnect() {
    setState(() {
      _connectionStatus = 'disconnected';
      _currentIp = '192.168.1.100';
      _stopConnectionTimer();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Emergency disconnect activated'),
        backgroundColor: const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    if (_connectionStatus == 'connected') {
      setState(() {
        _ping = 40 + (DateTime.now().millisecond % 30);
        _serverLoad = 25 + (DateTime.now().millisecond % 40);
        _uploadSpeed = 1.0 + (DateTime.now().millisecond % 100) / 50.0;
        _downloadSpeed = 10.0 + (DateTime.now().millisecond % 200) / 10.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'VPN Rotator',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: _emergencyDisconnect,
            icon: CustomIconWidget(
              iconName: 'power_settings_new',
              color: const Color(0xFFE57373),
              size: 6.w,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -500) {
                setState(() {
                  _showAdditionalStats = !_showAdditionalStats;
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Connection Status
                  GestureDetector(
                    onLongPress: _showServerSelection,
                    child: ConnectionStatusWidget(
                      status: _connectionStatus,
                      serverLocation:
                          _currentServer['name'] as String? ?? 'No Server',
                      flagUrl: _currentServer['flag'] as String? ?? '',
                      onToggle: _toggleConnection,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Connection Info
                  ConnectionInfoWidget(
                    currentIp: _currentIp,
                    connectionDuration: _connectionDuration,
                  ),
                  SizedBox(height: 2.h),

                  // Server Rotation
                  if (_autoRotationEnabled && _connectionStatus == 'connected')
                    ServerRotationWidget(
                      remainingSeconds: _rotationCountdown,
                      progress: 1.0 - (_rotationCountdown / 1800.0),
                      onRotateNow: _rotateNow,
                    ),
                  if (_autoRotationEnabled && _connectionStatus == 'connected')
                    SizedBox(height: 2.h),

                  // Connection Metrics
                  if (_connectionStatus == 'connected')
                    ConnectionMetricsWidget(
                      uploadSpeed: _uploadSpeed,
                      downloadSpeed: _downloadSpeed,
                      totalDataUsage: _totalDataUsage,
                      speedHistory: _speedHistory,
                    ),
                  if (_connectionStatus == 'connected') SizedBox(height: 2.h),

                  // Quick Settings
                  QuickSettingsWidget(
                    killSwitchEnabled: _killSwitchEnabled,
                    autoRotationEnabled: _autoRotationEnabled,
                    notificationsEnabled: _notificationsEnabled,
                    onKillSwitchChanged: (value) {
                      setState(() {
                        _killSwitchEnabled = value;
                      });
                    },
                    onAutoRotationChanged: (value) {
                      setState(() {
                        _autoRotationEnabled = value;
                      });
                    },
                    onNotificationsChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),

                  // Additional Stats (shown on swipe down)
                  if (_showAdditionalStats &&
                      _connectionStatus == 'connected') ...[
                    SizedBox(height: 2.h),
                    AdditionalStatsWidget(
                      ping: _ping,
                      serverLoad: _serverLoad,
                      protocol: _protocol,
                    ),
                  ],

                  SizedBox(height: 10.h), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navigate to different screens based on index
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/server-selection-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/settings-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/connection-logs-screen');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _currentIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dns',
              color: _currentIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            label: 'Servers',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: _currentIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'history',
              color: _currentIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
