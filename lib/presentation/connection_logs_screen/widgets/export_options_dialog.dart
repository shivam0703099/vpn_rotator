import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportOptionsDialog extends StatefulWidget {
  final Function(String format, DateTimeRange? dateRange) onExport;

  const ExportOptionsDialog({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog> {
  String _selectedFormat = 'CSV';
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Export Connection Logs',
        style: AppTheme.lightTheme.textTheme.titleMedium,
      ),
      content: SizedBox(
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'CSV',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    value: 'CSV',
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'PDF',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    value: 'PDF',
                    groupValue: _selectedFormat,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Date Range (Optional)',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 2.h),
            InkWell(
              onTap: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: AppTheme.lightTheme.colorScheme,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateRange = picked;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDateRange != null
                            ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                            : 'All dates',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: _selectedDateRange != null
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'calendar_today',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedDateRange != null) ...[
              SizedBox(height: 1.h),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
                child: Text(
                  'Clear date range',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onExport(_selectedFormat, _selectedDateRange);
            Navigator.of(context).pop();
          },
          child: Text('Export'),
        ),
      ],
    );
  }
}
