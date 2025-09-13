import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final String status;
  final String serverLocation;
  final String flagUrl;
  final VoidCallback onToggle;

  const ConnectionStatusWidget({
    Key? key,
    required this.status,
    required this.serverLocation,
    required this.flagUrl,
    required this.onToggle,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'connected':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'connecting':
        return const Color(0xFFFF9800);
      case 'disconnected':
      default:
        return const Color(0xFFE57373);
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'connected':
        return 'Connected';
      case 'connecting':
        return 'Connecting...';
      case 'disconnected':
      default:
        return 'Disconnected';
    }
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: status.toLowerCase() == 'connecting'
                ? Center(
                    child: SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Center(
                    child: CustomIconWidget(
                      iconName: status.toLowerCase() == 'connected'
                          ? 'check'
                          : 'close',
                      color: Colors.white,
                      size: 8.w,
                    ),
                  ),
          ),
          SizedBox(height: 2.h),

          // Status text
          Text(
            _getStatusText(),
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          // Server location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomImageWidget(
                imageUrl: flagUrl,
                width: 6.w,
                height: 4.w,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  serverLocation,
                  style: AppTheme.lightTheme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Connection toggle button
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 60.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  status.toLowerCase() == 'connected'
                      ? 'Disconnect'
                      : 'Connect',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
