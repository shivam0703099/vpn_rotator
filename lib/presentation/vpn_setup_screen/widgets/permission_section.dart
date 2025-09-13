import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionSection extends StatefulWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const PermissionSection({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  State<PermissionSection> createState() => _PermissionSectionState();
}

class _PermissionSectionState extends State<PermissionSection> {
  bool _isRequestingPermission = false;
  bool _permissionGranted = false;

  Future<void> _requestVpnPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      // Simulate platform-specific permission request
      await Future.delayed(const Duration(seconds: 2));

      // Mock permission grant for demo
      setState(() {
        _permissionGranted = true;
        _isRequestingPermission = false;
      });

      widget.onPermissionGranted?.call();
    } catch (e) {
      setState(() {
        _isRequestingPermission = false;
      });
      widget.onPermissionDenied?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _permissionGranted
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _permissionGranted
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _permissionGranted ? 'check_circle' : 'security',
                  color: _permissionGranted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _permissionGranted
                          ? 'VPN Permission Granted'
                          : 'VPN Permission Required',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _permissionGranted
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _permissionGranted
                          ? 'Your device is ready for secure VPN connections'
                          : kIsWeb
                              ? 'Browser-based VPN configuration required'
                              : 'Allow VPN profile installation for secure connections',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_permissionGranted) ...[
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isRequestingPermission ? null : _requestVpnPermission,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isRequestingPermission
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Requesting Permission...',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        kIsWeb
                            ? 'Configure Browser VPN'
                            : 'Grant VPN Permission',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
