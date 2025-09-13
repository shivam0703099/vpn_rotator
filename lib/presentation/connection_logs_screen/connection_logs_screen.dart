import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/empty_logs_state.dart';
import './widgets/export_options_dialog.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/log_entry_card.dart';
import './widgets/search_filter_bar.dart';

class ConnectionLogsScreen extends StatefulWidget {
  const ConnectionLogsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionLogsScreen> createState() => _ConnectionLogsScreenState();
}

class _ConnectionLogsScreenState extends State<ConnectionLogsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  Set<int> _selectedLogIds = {};
  bool _isMultiSelectMode = false;
  bool _isLoading = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 3);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _allLogs = [
      {
        "id": 1,
        "timestamp": DateTime.now().subtract(Duration(hours: 2)),
        "serverLocation": "New York, United States",
        "countryCode": "us",
        "duration": "2h 15m",
        "dataTransferred": "1.2 GB",
        "status": "connected",
        "ipAddress": "192.168.1.100",
        "protocol": "OpenVPN",
        "disconnectReason": "User initiated",
        "averageSpeed": "45.2 Mbps"
      },
      {
        "id": 2,
        "timestamp": DateTime.now().subtract(Duration(hours: 5)),
        "serverLocation": "London, United Kingdom",
        "countryCode": "gb",
        "duration": "1h 32m",
        "dataTransferred": "850 MB",
        "status": "manual_disconnect",
        "ipAddress": "10.0.0.50",
        "protocol": "IKEv2",
        "disconnectReason": "User initiated",
        "averageSpeed": "38.7 Mbps"
      },
      {
        "id": 3,
        "timestamp": DateTime.now().subtract(Duration(days: 1, hours: 3)),
        "serverLocation": "Tokyo, Japan",
        "countryCode": "jp",
        "duration": "45m",
        "dataTransferred": "320 MB",
        "status": "failed",
        "ipAddress": "N/A",
        "protocol": "WireGuard",
        "disconnectReason": "Connection timeout",
        "averageSpeed": "0 Mbps"
      },
      {
        "id": 4,
        "timestamp": DateTime.now().subtract(Duration(days: 1, hours: 8)),
        "serverLocation": "Frankfurt, Germany",
        "countryCode": "de",
        "duration": "3h 22m",
        "dataTransferred": "2.1 GB",
        "status": "connected",
        "ipAddress": "172.16.0.25",
        "protocol": "OpenVPN",
        "disconnectReason": "Server maintenance",
        "averageSpeed": "52.1 Mbps"
      },
      {
        "id": 5,
        "timestamp": DateTime.now().subtract(Duration(days: 2)),
        "serverLocation": "Sydney, Australia",
        "countryCode": "au",
        "duration": "1h 18m",
        "dataTransferred": "640 MB",
        "status": "connected",
        "ipAddress": "203.0.113.42",
        "protocol": "WireGuard",
        "disconnectReason": "User initiated",
        "averageSpeed": "41.8 Mbps"
      },
      {
        "id": 6,
        "timestamp": DateTime.now().subtract(Duration(days: 3, hours: 2)),
        "serverLocation": "Toronto, Canada",
        "countryCode": "ca",
        "duration": "2h 45m",
        "dataTransferred": "1.8 GB",
        "status": "manual_disconnect",
        "ipAddress": "198.51.100.15",
        "protocol": "IKEv2",
        "disconnectReason": "User initiated",
        "averageSpeed": "47.3 Mbps"
      },
      {
        "id": 7,
        "timestamp": DateTime.now().subtract(Duration(days: 4)),
        "serverLocation": "Amsterdam, Netherlands",
        "countryCode": "nl",
        "duration": "25m",
        "dataTransferred": "180 MB",
        "status": "failed",
        "ipAddress": "N/A",
        "protocol": "OpenVPN",
        "disconnectReason": "Authentication failed",
        "averageSpeed": "0 Mbps"
      },
      {
        "id": 8,
        "timestamp": DateTime.now().subtract(Duration(days: 5, hours: 6)),
        "serverLocation": "Singapore",
        "countryCode": "sg",
        "duration": "4h 12m",
        "dataTransferred": "3.2 GB",
        "status": "connected",
        "ipAddress": "192.0.2.88",
        "protocol": "WireGuard",
        "disconnectReason": "User initiated",
        "averageSpeed": "55.9 Mbps"
      }
    ];

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final serverLocation =
              (log['serverLocation'] as String).toLowerCase();
          final status = (log['status'] as String).toLowerCase();
          final timestamp = log['timestamp'] as DateTime;
          final dateString =
              '${timestamp.day}/${timestamp.month}/${timestamp.year}';

          if (!serverLocation.contains(query) &&
              !status.contains(query) &&
              !dateString.contains(query)) {
            return false;
          }
        }

        // Date range filter
        if (_activeFilters['dateRange'] != null) {
          final dateRange = _activeFilters['dateRange'] as DateTimeRange;
          final logDate = log['timestamp'] as DateTime;
          if (logDate.isBefore(dateRange.start) ||
              logDate.isAfter(dateRange.end)) {
            return false;
          }
        }

        // Status filter
        if (_activeFilters['status'] != null &&
            (_activeFilters['status'] as List).isNotEmpty) {
          final statusList = _activeFilters['status'] as List<String>;
          final logStatus = (log['status'] as String);
          final formattedStatus = logStatus == 'manual_disconnect'
              ? 'Manual Disconnect'
              : logStatus == 'connected'
                  ? 'Connected'
                  : 'Failed';
          if (!statusList.contains(formattedStatus)) {
            return false;
          }
        }

        // Location filter
        if (_activeFilters['locations'] != null &&
            (_activeFilters['locations'] as List).isNotEmpty) {
          final locationList = _activeFilters['locations'] as List<String>;
          final logLocation = log['serverLocation'] as String;
          bool locationMatch = false;
          for (String location in locationList) {
            if (logLocation.contains(location)) {
              locationMatch = true;
              break;
            }
          }
          if (!locationMatch) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportOptionsDialog(
        onExport: _exportLogs,
      ),
    );
  }

  Future<void> _exportLogs(String format, DateTimeRange? dateRange) async {
    List<Map<String, dynamic>> logsToExport = _filteredLogs;

    if (dateRange != null) {
      logsToExport = _filteredLogs.where((log) {
        final logDate = log['timestamp'] as DateTime;
        return !logDate.isBefore(dateRange.start) &&
            !logDate.isAfter(dateRange.end);
      }).toList();
    }

    if (format == 'CSV') {
      await _exportToCSV(logsToExport);
    } else {
      await _exportToPDF(logsToExport);
    }
  }

  Future<void> _exportToCSV(List<Map<String, dynamic>> logs) async {
    final StringBuffer csvBuffer = StringBuffer();

    // CSV Header
    csvBuffer.writeln(
        'Date,Time,Server Location,Duration,Data Transferred,Status,IP Address,Protocol,Disconnect Reason,Average Speed');

    // CSV Data
    for (final log in logs) {
      final timestamp = log['timestamp'] as DateTime;
      final date = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
      final time =
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

      csvBuffer.writeln([
        date,
        time,
        log['serverLocation'],
        log['duration'],
        log['dataTransferred'],
        log['status'],
        log['ipAddress'],
        log['protocol'],
        log['disconnectReason'],
        log['averageSpeed']
      ].map((field) => '"$field"').join(','));
    }

    await _downloadFile(csvBuffer.toString(), 'vpn_connection_logs.csv');
  }

  Future<void> _exportToPDF(List<Map<String, dynamic>> logs) async {
    final StringBuffer pdfContent = StringBuffer();

    pdfContent.writeln('VPN Connection Logs Report');
    pdfContent.writeln(
        'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    pdfContent.writeln('Total Entries: ${logs.length}');
    pdfContent.writeln('\n');

    for (final log in logs) {
      final timestamp = log['timestamp'] as DateTime;
      pdfContent.writeln(
          'Date: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}');
      pdfContent.writeln('Server: ${log['serverLocation']}');
      pdfContent.writeln('Duration: ${log['duration']}');
      pdfContent.writeln('Data: ${log['dataTransferred']}');
      pdfContent.writeln('Status: ${log['status']}');
      pdfContent.writeln('IP: ${log['ipAddress']}');
      pdfContent.writeln('Protocol: ${log['protocol']}');
      pdfContent.writeln('Disconnect Reason: ${log['disconnectReason']}');
      pdfContent.writeln('Average Speed: ${log['averageSpeed']}');
      pdfContent.writeln('---');
    }

    await _downloadFile(pdfContent.toString(), 'vpn_connection_logs.txt');
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved to ${file.path}'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save file'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _deleteLog(int logId) {
    setState(() {
      _allLogs.removeWhere((log) => log['id'] == logId);
      _selectedLogIds.remove(logId);
    });
    _applyFilters();
  }

  void _shareLog(Map<String, dynamic> log) {
    final timestamp = log['timestamp'] as DateTime;
    final shareText = '''
VPN Connection Log

Date: ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}
Server: ${log['serverLocation']}
Duration: ${log['duration']}
Data Transferred: ${log['dataTransferred']}
Status: ${log['status']}
IP Address: ${log['ipAddress']}
Protocol: ${log['protocol']}
Average Speed: ${log['averageSpeed']}
''';

    if (kIsWeb) {
      html.window.navigator.clipboard?.writeText(shareText);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Log details copied to clipboard')),
      );
    } else {
      // On mobile, this would use the system share sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Share functionality would open system share sheet')),
      );
    }
  }

  void _toggleLogSelection(int logId) {
    setState(() {
      if (_selectedLogIds.contains(logId)) {
        _selectedLogIds.remove(logId);
      } else {
        _selectedLogIds.add(logId);
      }

      if (_selectedLogIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode(int logId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedLogIds.add(logId);
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedLogIds.clear();
    });
  }

  void _deleteSelectedLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Logs'),
        content: Text(
            'Are you sure you want to delete ${_selectedLogIds.length} log entries?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allLogs
                    .removeWhere((log) => _selectedLogIds.contains(log['id']));
                _selectedLogIds.clear();
                _isMultiSelectMode = false;
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshLogs() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // In a real app, this would fetch fresh data from the server
    _loadMockData();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode
              ? '${_selectedLogIds.length} Selected'
              : 'Connection Logs',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: _exitMultiSelectMode,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
        actions: _isMultiSelectMode
            ? [
                IconButton(
                  onPressed: _deleteSelectedLogs,
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 24,
                  ),
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/onboarding-flow');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/dashboard-screen');
                break;
              case 2:
                Navigator.pushReplacementNamed(
                    context, '/server-selection-screen');
                break;
              case 3:
                // Current screen - do nothing
                break;
              case 4:
                Navigator.pushReplacementNamed(context, '/settings-screen');
                break;
            }
          },
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'home',
                color: _tabController.index == 0
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Home',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'dashboard',
                color: _tabController.index == 1
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Dashboard',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'public',
                color: _tabController.index == 2
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Servers',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              text: 'Logs',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'settings',
                color: _tabController.index == 4
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: 'Settings',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!_isMultiSelectMode)
            SearchFilterBar(
              onSearchChanged: _onSearchChanged,
              onFilterPressed: _showFilterBottomSheet,
              onExportPressed: _showExportDialog,
            ),
          Expanded(
            child: _filteredLogs.isEmpty
                ? _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No logs match your search',
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try adjusting your search terms or filters',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : EmptyLogsState()
                : RefreshIndicator(
                    onRefresh: _refreshLogs,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = _filteredLogs[index];
                        final logId = log['id'] as int;

                        return LogEntryCard(
                          logEntry: log,
                          isSelected: _selectedLogIds.contains(logId),
                          onDelete: () => _deleteLog(logId),
                          onShare: () => _shareLog(log),
                          onSelectionChanged: _isMultiSelectMode
                              ? () => _toggleLogSelection(logId)
                              : () => _enterMultiSelectMode(logId),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
