import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdditionalStatsWidget extends StatelessWidget {
  final int ping;
  final int serverLoad;
  final String protocol;

  const AdditionalStatsWidget({
    Key? key,
    required this.ping,
    required this.serverLoad,
    required this.protocol,
  }) : super(key: key);

  Color _getPingColor() {
    if (ping <= 50) return const Color(0xFF4CAF50);
    if (ping <= 100) return const Color(0xFFFF9800);
    return const Color(0xFFE57373);
  }

  Color _getServerLoadColor() {
    if (serverLoad <= 30) return const Color(0xFF4CAF50);
    if (serverLoad <= 70) return const Color(0xFFFF9800);
    return const Color(0xFFE57373);
  }

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
            'Connection Details',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              // Ping
              Expanded(
                child: _buildStatCard(
                  icon: 'network_ping',
                  title: 'Ping',
                  value: '${ping}ms',
                  color: _getPingColor(),
                ),
              ),
              SizedBox(width: 2.w),

              // Server Load
              Expanded(
                child: _buildStatCard(
                  icon: 'storage',
                  title: 'Server Load',
                  value: '$serverLoad%',
                  color: _getServerLoadColor(),
                ),
              ),
              SizedBox(width: 2.w),

              // Protocol
              Expanded(
                child: _buildStatCard(
                  icon: 'vpn_lock',
                  title: 'Protocol',
                  value: protocol,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
