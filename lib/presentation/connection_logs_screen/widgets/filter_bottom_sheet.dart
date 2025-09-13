import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _selectedDateRange = _filters['dateRange'] as DateTimeRange?;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filters.clear();
                      _selectedDateRange = null;
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
                Text(
                  'Filter Logs',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    widget.onFiltersChanged(_filters);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSection(),
                  SizedBox(height: 3.h),
                  _buildConnectionStatusSection(),
                  SizedBox(height: 3.h),
                  _buildServerLocationSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
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
                _filters['dateRange'] = picked;
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
                Text(
                  _selectedDateRange != null
                      ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                      : 'Select date range',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: _selectedDateRange != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.6),
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
      ],
    );
  }

  Widget _buildConnectionStatusSection() {
    final List<String> statuses = ['Connected', 'Failed', 'Manual Disconnect'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Status',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 2.h),
        ...statuses.map((status) {
          final isSelected =
              (_filters['status'] as List<String>? ?? []).contains(status);
          return CheckboxListTile(
            title: Text(
              status,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                final statusList =
                    (_filters['status'] as List<String>? ?? <String>[]);
                if (value == true) {
                  statusList.add(status);
                } else {
                  statusList.remove(status);
                }
                _filters['status'] = statusList;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildServerLocationSection() {
    final List<String> locations = [
      'United States',
      'United Kingdom',
      'Germany',
      'Japan',
      'Australia',
      'Canada',
      'Netherlands',
      'Singapore'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server Location',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 2.h),
        ...locations.map((location) {
          final isSelected =
              (_filters['locations'] as List<String>? ?? []).contains(location);
          return CheckboxListTile(
            title: Text(
              location,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                final locationList =
                    (_filters['locations'] as List<String>? ?? <String>[]);
                if (value == true) {
                  locationList.add(location);
                } else {
                  locationList.remove(location);
                }
                _filters['locations'] = locationList;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }
}
