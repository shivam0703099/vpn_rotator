import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickSettingsWidget extends StatelessWidget {
  final bool killSwitchEnabled;
  final bool autoRotationEnabled;
  final bool notificationsEnabled;
  final ValueChanged<bool> onKillSwitchChanged;
  final ValueChanged<bool> onAutoRotationChanged;
  final ValueChanged<bool> onNotificationsChanged;

  const QuickSettingsWidget({
    Key? key,
    required this.killSwitchEnabled,
    required this.autoRotationEnabled,
    required this.notificationsEnabled,
    required this.onKillSwitchChanged,
    required this.onAutoRotationChanged,
    required this.onNotificationsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Settings',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Kill Switch
          _buildSettingRow(
            icon: 'security',
            title: 'Kill Switch',
            subtitle: 'Block internet if VPN disconnects',
            value: killSwitchEnabled,
            onChanged: onKillSwitchChanged,
            iconColor: const Color(0xFFE57373),
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            height: 3.h,
          ),

          // Auto Rotation
          _buildSettingRow(
            icon: 'autorenew',
            title: 'Auto Rotation',
            subtitle: 'Automatically rotate servers',
            value: autoRotationEnabled,
            onChanged: onAutoRotationChanged,
            iconColor: AppTheme.lightTheme.colorScheme.primary,
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            height: 3.h,
          ),

          // Notifications
          _buildSettingRow(
            icon: 'notifications',
            title: 'Notifications',
            subtitle: 'Connection status alerts',
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
            iconColor: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: iconColor,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      ],
    );
  }
}
