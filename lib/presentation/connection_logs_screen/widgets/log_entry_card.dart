import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogEntryCard extends StatefulWidget {
  final Map<String, dynamic> logEntry;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const LogEntryCard({
    Key? key,
    required this.logEntry,
    this.onDelete,
    this.onShare,
    this.isSelected = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<LogEntryCard> createState() => _LogEntryCardState();
}

class _LogEntryCardState extends State<LogEntryCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  Widget _buildStatusIcon(String status) {
    Color statusColor;
    String iconName;

    switch (status.toLowerCase()) {
      case 'connected':
        statusColor = AppTheme.lightTheme.colorScheme.primary;
        iconName = 'check_circle';
        break;
      case 'failed':
        statusColor = AppTheme.lightTheme.colorScheme.error;
        iconName = 'error';
        break;
      case 'manual_disconnect':
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        iconName = 'stop_circle';
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        iconName = 'help_outline';
    }

    return CustomIconWidget(
      iconName: iconName,
      color: statusColor,
      size: 20,
    );
  }

  Widget _buildCountryFlag(String countryCode) {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: CustomImageWidget(
        imageUrl: 'https://flagcdn.com/w40/${countryCode.toLowerCase()}.png',
        width: 24,
        height: 16,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.logEntry['timestamp'] as DateTime;
    final serverLocation = widget.logEntry['serverLocation'] as String;
    final countryCode = widget.logEntry['countryCode'] as String;
    final duration = widget.logEntry['duration'] as String;
    final dataTransferred = widget.logEntry['dataTransferred'] as String;
    final status = widget.logEntry['status'] as String;

    return Dismissible(
      key: Key(widget.logEntry['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 4.w),
            CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 20,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Log Entry',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            content: Text(
              'Are you sure you want to delete this log entry?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        widget.onDelete?.call();
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: InkWell(
          onTap: _toggleExpanded,
          onLongPress: widget.onSelectionChanged,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    if (widget.isSelected)
                      Container(
                        margin: EdgeInsets.only(right: 3.w),
                        child: CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    _buildCountryFlag(countryCode),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serverLocation,
                            style: AppTheme.lightTheme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusIcon(status),
                        SizedBox(height: 0.5.h),
                        Text(
                          duration,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: _isExpanded ? 'expand_less' : 'expand_more',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    margin: EdgeInsets.only(top: 2.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Data Transferred', dataTransferred),
                        SizedBox(height: 1.h),
                        _buildDetailRow('IP Address',
                            widget.logEntry['ipAddress'] as String? ?? 'N/A'),
                        SizedBox(height: 1.h),
                        _buildDetailRow(
                            'Protocol',
                            widget.logEntry['protocol'] as String? ??
                                'OpenVPN'),
                        SizedBox(height: 1.h),
                        _buildDetailRow(
                            'Disconnect Reason',
                            widget.logEntry['disconnectReason'] as String? ??
                                'User initiated'),
                        SizedBox(height: 1.h),
                        _buildDetailRow(
                            'Average Speed',
                            widget.logEntry['averageSpeed'] as String? ??
                                '0 Mbps'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
