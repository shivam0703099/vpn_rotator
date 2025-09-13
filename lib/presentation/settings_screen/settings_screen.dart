import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/protocol_selection_widget.dart';
import './widgets/settings_row_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tab_bar_widget.dart';
import './widgets/settings_toggle_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Settings state variables
  bool _killSwitchEnabled = true;
  bool _autoConnectUntrustedWifi = false;
  bool _connectionAlerts = true;
  bool _rotationNotifications = true;
  bool _securityWarnings = true;
  bool _leakProtection = true;
  bool _dataCollection = false;
  bool _backgroundRefresh = true;
  bool _debugMode = false;
  String _selectedProtocol = 'WireGuard';
  String _selectedDNS = 'Auto';

  // Mock user data
  final Map<String, dynamic> _userSettings = {
    "subscription": {
      "plan": "Premium",
      "status": "Active",
      "expiryDate": "2024-12-15",
      "dataUsed": "45.2 GB",
      "dataLimit": "Unlimited"
    },
    "account": {
      "email": "user@vpnrotator.com",
      "joinDate": "2023-08-15",
      "deviceCount": 3,
      "maxDevices": 5
    },
    "app": {
      "version": "2.1.4",
      "buildNumber": "214",
      "lastUpdate": "2024-09-10"
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: SettingsTabBarWidget(tabController: _tabController),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildServersTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'dashboard',
            size: 20.w,
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            'Dashboard',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/dashboard-screen'),
            child: Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildServersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'dns',
            size: 20.w,
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            'Server Selection',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/server-selection-screen'),
            child: Text('Select Servers'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Connection Settings Section
          SettingsSectionWidget(
            title: 'Connection',
            children: [
              SettingsToggleWidget(
                title: 'Kill Switch',
                subtitle: 'Block internet if VPN disconnects',
                value: _killSwitchEnabled,
                onChanged: (value) =>
                    setState(() => _killSwitchEnabled = value),
                leading: CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                isFirst: true,
              ),
              SettingsToggleWidget(
                title: 'Auto-Connect on Untrusted WiFi',
                subtitle: 'Automatically connect when joining public networks',
                value: _autoConnectUntrustedWifi,
                onChanged: (value) =>
                    setState(() => _autoConnectUntrustedWifi = value),
                leading: CustomIconWidget(
                  iconName: 'wifi',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
              SettingsRowWidget(
                title: 'VPN Protocol',
                subtitle: _selectedProtocol,
                leading: CustomIconWidget(
                  iconName: 'vpn_key',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _showProtocolSelection,
                isLast: true,
              ),
            ],
          ),

          // Notifications Section
          SettingsSectionWidget(
            title: 'Notifications',
            children: [
              SettingsToggleWidget(
                title: 'Connection Alerts',
                subtitle: 'Notify when VPN connects or disconnects',
                value: _connectionAlerts,
                onChanged: (value) => setState(() => _connectionAlerts = value),
                leading: CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                isFirst: true,
              ),
              SettingsToggleWidget(
                title: 'Rotation Notifications',
                subtitle: 'Notify when server rotation occurs',
                value: _rotationNotifications,
                onChanged: (value) =>
                    setState(() => _rotationNotifications = value),
                leading: CustomIconWidget(
                  iconName: 'sync',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
              ),
              SettingsToggleWidget(
                title: 'Security Warnings',
                subtitle: 'Alert for potential security issues',
                value: _securityWarnings,
                onChanged: (value) => setState(() => _securityWarnings = value),
                leading: CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                isLast: true,
              ),
            ],
          ),

          // Privacy Section
          SettingsSectionWidget(
            title: 'Privacy',
            children: [
              SettingsRowWidget(
                title: 'DNS Settings',
                subtitle: _selectedDNS,
                leading: CustomIconWidget(
                  iconName: 'dns',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _showDNSSettings,
                isFirst: true,
              ),
              SettingsToggleWidget(
                title: 'Leak Protection',
                subtitle: 'Prevent DNS and IP leaks',
                value: _leakProtection,
                onChanged: (value) => setState(() => _leakProtection = value),
                leading: CustomIconWidget(
                  iconName: 'shield',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
              ),
              SettingsToggleWidget(
                title: 'Data Collection',
                subtitle: 'Allow anonymous usage analytics',
                value: _dataCollection,
                onChanged: (value) => setState(() => _dataCollection = value),
                leading: CustomIconWidget(
                  iconName: 'analytics',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                isLast: true,
              ),
            ],
          ),

          // Advanced Section
          SettingsSectionWidget(
            title: 'Advanced',
            children: [
              SettingsToggleWidget(
                title: 'Background Refresh',
                subtitle: 'Allow app to refresh in background',
                value: _backgroundRefresh,
                onChanged: (value) =>
                    setState(() => _backgroundRefresh = value),
                leading: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                isFirst: true,
              ),
              SettingsRowWidget(
                title: 'Battery Optimization',
                subtitle: 'Manage power usage settings',
                leading: CustomIconWidget(
                  iconName: 'battery_full',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _showBatteryOptimization,
              ),
              SettingsToggleWidget(
                title: 'Debug Mode',
                subtitle: 'Enable detailed logging for troubleshooting',
                value: _debugMode,
                onChanged: (value) => setState(() => _debugMode = value),
                leading: CustomIconWidget(
                  iconName: 'bug_report',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                isLast: true,
              ),
            ],
          ),

          // Account Section
          SettingsSectionWidget(
            title: 'Account',
            children: [
              SettingsRowWidget(
                title: 'Subscription Status',
                subtitle:
                    '${(_userSettings["subscription"] as Map<String, dynamic>)["plan"]} - ${(_userSettings["subscription"] as Map<String, dynamic>)["status"]}',
                leading: CustomIconWidget(
                  iconName: 'card_membership',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _showSubscriptionDetails,
                isFirst: true,
              ),
              SettingsRowWidget(
                title: 'Usage Statistics',
                subtitle:
                    '${(_userSettings["subscription"] as Map<String, dynamic>)["dataUsed"]} used this month',
                leading: CustomIconWidget(
                  iconName: 'data_usage',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: () =>
                    Navigator.pushNamed(context, '/connection-logs-screen'),
              ),
              SettingsRowWidget(
                title: 'Account Management',
                subtitle: ((_userSettings["account"]
                    as Map<String, dynamic>)["email"] as String),
                leading: CustomIconWidget(
                  iconName: 'account_circle',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _showAccountManagement,
                isLast: true,
              ),
            ],
          ),

          // About Section
          SettingsSectionWidget(
            title: 'About',
            children: [
              SettingsRowWidget(
                title: 'App Version',
                subtitle:
                    'Version ${(_userSettings["app"] as Map<String, dynamic>)["version"]} (${(_userSettings["app"] as Map<String, dynamic>)["buildNumber"]})',
                leading: CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                isFirst: true,
              ),
              SettingsRowWidget(
                title: 'Privacy Policy',
                leading: CustomIconWidget(
                  iconName: 'privacy_tip',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'open_in_new',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _openPrivacyPolicy,
              ),
              SettingsRowWidget(
                title: 'Terms of Service',
                leading: CustomIconWidget(
                  iconName: 'description',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'open_in_new',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _openTermsOfService,
              ),
              SettingsRowWidget(
                title: 'Contact Support',
                leading: CustomIconWidget(
                  iconName: 'support',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                trailing: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onTap: _contactSupport,
                isLast: true,
              ),
            ],
          ),

          // Reset Section
          SettingsSectionWidget(
            title: 'Reset',
            children: [
              SettingsRowWidget(
                title: 'Clear Connection Logs',
                subtitle: 'Remove all stored connection history',
                leading: CustomIconWidget(
                  iconName: 'clear_all',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
                onTap: _clearLogs,
                isFirst: true,
              ),
              SettingsRowWidget(
                title: 'Reset to Defaults',
                subtitle: 'Restore all settings to default values',
                leading: CustomIconWidget(
                  iconName: 'restore',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                onTap: _resetToDefaults,
              ),
              SettingsRowWidget(
                title: 'Remove VPN Profiles',
                subtitle: 'Delete all VPN configurations from device',
                leading: CustomIconWidget(
                  iconName: 'delete_forever',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                onTap: _removeVPNProfiles,
                isLast: true,
              ),
            ],
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Settings'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Type to search settings...',
            prefixIcon: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProtocolSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ProtocolSelectionWidget(
              selectedProtocol: _selectedProtocol,
              onProtocolChanged: (protocol) {
                setState(() => _selectedProtocol = protocol);
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: 'Protocol changed to $protocol',
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDNSSettings() {
    final dnsOptions = ['Auto', 'Cloudflare', 'Google', 'OpenDNS', 'Custom'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('DNS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: dnsOptions
              .map((dns) => RadioListTile<String>(
                    title: Text(dns),
                    value: dns,
                    groupValue: _selectedDNS,
                    onChanged: (value) {
                      setState(() => _selectedDNS = value!);
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: 'DNS changed to $value',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showBatteryOptimization() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Battery Optimization'),
        content: Text(
          'To ensure VPN Rotator works properly in the background, please disable battery optimization for this app in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Opening system settings...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDetails() {
    final subscription = _userSettings["subscription"] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscription Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${subscription["plan"]}'),
            SizedBox(height: 1.h),
            Text('Status: ${subscription["status"]}'),
            SizedBox(height: 1.h),
            Text('Expires: ${subscription["expiryDate"]}'),
            SizedBox(height: 1.h),
            Text('Data Used: ${subscription["dataUsed"]}'),
            SizedBox(height: 1.h),
            Text('Data Limit: ${subscription["dataLimit"]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAccountManagement() {
    final account = _userSettings["account"] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${account["email"]}'),
            SizedBox(height: 1.h),
            Text('Member Since: ${account["joinDate"]}'),
            SizedBox(height: 1.h),
            Text('Devices: ${account["deviceCount"]}/${account["maxDevices"]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Opening account settings...',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            child: Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    Fluttertoast.showToast(
      msg: 'Opening Privacy Policy...',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _openTermsOfService() {
    Fluttertoast.showToast(
      msg: 'Opening Terms of Service...',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Email Support'),
              subtitle: Text('support@vpnrotator.com'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: 'Opening email client...',
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'chat',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              title: Text('Live Chat'),
              subtitle: Text('Available 24/7'),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: 'Starting live chat...',
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Connection Logs'),
        content: Text(
            'Are you sure you want to clear all connection logs? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Connection logs cleared',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset to Defaults'),
        content: Text(
            'Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _killSwitchEnabled = true;
                _autoConnectUntrustedWifi = false;
                _connectionAlerts = true;
                _rotationNotifications = true;
                _securityWarnings = true;
                _leakProtection = true;
                _dataCollection = false;
                _backgroundRefresh = true;
                _debugMode = false;
                _selectedProtocol = 'WireGuard';
                _selectedDNS = 'Auto';
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Settings reset to defaults',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _removeVPNProfiles() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove VPN Profiles'),
        content: Text(
            'This will remove all VPN configurations from your device. You will need to set up VPN connections again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'VPN profiles removed',
                toastLength: Toast.LENGTH_SHORT,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
}
