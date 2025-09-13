import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServerListItemWidget extends StatelessWidget {
  final Map<String, dynamic> server;
  final bool isCurrentServer;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onConnect;
  final VoidCallback onSpeedTest;

  const ServerListItemWidget({
    Key? key,
    required this.server,
    required this.isCurrentServer,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onConnect,
    required this.onSpeedTest,
  }) : super(key: key);

  Color _getLoadColor(String load) {
    switch (load.toLowerCase()) {
      case 'low':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'medium':
        return Colors.orange;
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onConnect(),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            icon: Icons.power_settings_new,
            label: 'Connect',
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: (_) => onFavoriteToggle(),
            backgroundColor: (server['isFavorite'] as bool)
                ? Colors.orange
                : AppTheme.lightTheme.colorScheme.secondary,
            foregroundColor: Colors.white,
            icon:
                (server['isFavorite'] as bool) ? Icons.star : Icons.star_border,
            label: 'Favorite',
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: (_) => onSpeedTest(),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            foregroundColor: Colors.white,
            icon: Icons.speed,
            label: 'Speed Test',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: isCurrentServer
              ? (isDark
                  ? AppTheme.darkTheme.colorScheme.primaryContainer
                  : AppTheme.lightTheme.colorScheme.primaryContainer)
              : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: isCurrentServer
              ? Border.all(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppTheme.shadowDark : AppTheme.shadowLight)
                  .withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showServerDetails(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Country Flag
                  Container(
                    width: 12.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (isDark
                            ? AppTheme.dividerDark
                            : AppTheme.dividerLight),
                        width: 0.5,
                      ),
                    ),
                    child: CustomImageWidget(
                      imageUrl: server['flagUrl'] as String,
                      width: 12.w,
                      height: 8.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Server Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                server['city'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isCurrentServer
                                          ? (isDark
                                              ? AppTheme.primaryDark
                                              : AppTheme.primaryLight)
                                          : null,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentServer) ...[
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight,
                                size: 5.w,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          server['country'] as String,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.onSurfaceVariantDark
                                        : AppTheme.onSurfaceVariantLight,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Server Load Indicator
                  Column(
                    children: [
                      Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: _getLoadColor(server['load'] as String),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        server['load'] as String,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 8.sp,
                              color: _getLoadColor(server['load'] as String),
                            ),
                      ),
                    ],
                  ),

                  SizedBox(width: 3.w),

                  // Ping Latency
                  Column(
                    children: [
                      Text(
                        '${server['ping']}ms',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: (server['ping'] as int) < 50
                                  ? AppTheme.lightTheme.colorScheme.tertiary
                                  : (server['ping'] as int) < 100
                                      ? Colors.orange
                                      : AppTheme.lightTheme.colorScheme.error,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'ping',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 8.sp,
                              color: isDark
                                  ? AppTheme.onSurfaceVariantDark
                                  : AppTheme.onSurfaceVariantLight,
                            ),
                      ),
                    ],
                  ),

                  SizedBox(width: 3.w),

                  // Favorite Star
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: (server['isFavorite'] as bool)
                            ? 'star'
                            : 'star_border',
                        color: (server['isFavorite'] as bool)
                            ? Colors.orange
                            : (isDark
                                ? AppTheme.onSurfaceVariantDark
                                : AppTheme.onSurfaceVariantLight),
                        size: 6.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showServerDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    SizedBox(height: 3.h),
                    _buildDetailRow(context, 'Location',
                        '${server['city']}, ${server['country']}'),
                    _buildDetailRow(
                        context, 'Server Load', server['load'] as String),
                    _buildDetailRow(
                        context, 'Ping Latency', '${server['ping']}ms'),
                    _buildDetailRow(context, 'Supported Protocols',
                        (server['protocols'] as List).join(', ')),
                    _buildDetailRow(
                        context, 'Server Capacity', '${server['capacity']}%'),
                    _buildDetailRow(context, 'P2P Support',
                        (server['p2pSupport'] as bool) ? 'Yes' : 'No'),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConnect();
                        },
                        child: const Text('Connect to Server'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
