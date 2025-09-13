import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_settings_section.dart';
import './widgets/install_profile_button.dart';
import './widgets/permission_section.dart';
import './widgets/server_selection_card.dart';
import './widgets/setup_progress_indicator.dart';

class VpnSetupScreen extends StatefulWidget {
  const VpnSetupScreen({super.key});

  @override
  State<VpnSetupScreen> createState() => _VpnSetupScreenState();
}

class _VpnSetupScreenState extends State<VpnSetupScreen> {
  int _currentStep = 0;
  bool _permissionGranted = false;
  bool _profileInstalled = false;
  bool _isLoading = false;
  String _loadingMessage = '';

  // Mock server data
  final List<Map<String, dynamic>> _availableServers = [
    {
      "id": 1,
      "country": "United States",
      "city": "New York",
      "flagUrl":
          "https://images.unsplash.com/photo-1485738422979-f5c462d49f74?w=100&h=60&fit=crop",
      "latency": 45,
      "status": "available",
      "load": 23,
      "premium": false,
    },
    {
      "id": 2,
      "country": "United Kingdom",
      "city": "London",
      "flagUrl":
          "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=100&h=60&fit=crop",
      "latency": 67,
      "status": "available",
      "load": 45,
      "premium": false,
    },
    {
      "id": 3,
      "country": "Germany",
      "city": "Berlin",
      "flagUrl":
          "https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=100&h=60&fit=crop",
      "latency": 89,
      "status": "busy",
      "load": 78,
      "premium": true,
    },
  ];

  Map<String, dynamic> _selectedServer = {};

  @override
  void initState() {
    super.initState();
    _selectedServer = _availableServers.first;
  }

  void _handlePermissionGranted() {
    setState(() {
      _permissionGranted = true;
      _currentStep = 1;
    });
  }

  void _handlePermissionDenied() {
    _showErrorDialog(
      'Permission Required',
      'VPN permission is required to proceed with the setup. Please grant permission to continue.',
    );
  }

  void _handleServerSelection() {
    _showServerSelectionBottomSheet();
  }

  void _handleProfileInstallation() {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Configuring secure connection...';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Installing certificates...';
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _profileInstalled = true;
          _currentStep = 2;
          _isLoading = false;
          _loadingMessage = '';
        });
        _showSuccessDialog();
      }
    });
  }

  void _showServerSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Text(
                    'Select Server',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search countries...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _availableServers.length,
                itemBuilder: (context, index) {
                  final server = _availableServers[index];
                  final isSelected = server['id'] == _selectedServer['id'];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedServer = server;
                        });
                        Navigator.pop(context);
                      },
                      leading: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CustomImageWidget(
                            imageUrl: server['flagUrl'] as String,
                            width: 10.w,
                            height: 10.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        server['country'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        server['city'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${server['latency']}ms',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: _getLatencyColor(server['latency'] as int),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${server['load']}% load',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.green,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Setup Complete!',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your VPN profile has been successfully installed. You can now enjoy secure browsing.',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/dashboard-screen');
                },
                child: Text(
                  'Go to Dashboard',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncompleteSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Incomplete Setup',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your VPN setup is not complete. Are you sure you want to go back?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue Setup',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Go Back',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLatencyColor(int latency) {
    if (latency < 50) return Colors.green;
    if (latency < 100) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_currentStep > 0 && !_profileInstalled) {
              _showIncompleteSetupDialog();
            } else {
              Navigator.pop(context);
            }
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'VPN Setup',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SetupProgressIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure Your Connection',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Follow these steps to configure your VPN profile and start browsing securely.',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    PermissionSection(
                      onPermissionGranted: _handlePermissionGranted,
                      onPermissionDenied: _handlePermissionDenied,
                    ),
                    if (_permissionGranted) ...[
                      SizedBox(height: 2.h),
                      ServerSelectionCard(
                        selectedServer: _selectedServer,
                        onTap: _handleServerSelection,
                      ),
                      SizedBox(height: 2.h),
                      InstallProfileButton(
                        isEnabled: _permissionGranted && !_profileInstalled,
                        onPressed: _handleProfileInstallation,
                      ),
                      SizedBox(height: 2.h),
                      const AdvancedSettingsSection(),
                    ],
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _loadingMessage,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Please wait while we configure your secure connection...',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
