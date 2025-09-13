import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChipsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = [
      {'key': 'all', 'label': 'All Servers', 'icon': 'public'},
      {'key': 'favorites', 'label': 'Favorites', 'icon': 'star'},
      {'key': 'low_latency', 'label': 'Low Latency', 'icon': 'speed'},
      {'key': 'p2p', 'label': 'P2P Optimized', 'icon': 'share'},
    ];

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: filter['icon'] as String,
                  size: 4.w,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppTheme.onSurfaceVariantDark
                          : AppTheme.onSurfaceVariantLight),
                ),
                SizedBox(width: 1.w),
                Text(
                  filter['label'] as String,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppTheme.onSurfaceVariantDark
                                : AppTheme.onSurfaceVariantLight),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ],
            ),
            onSelected: (selected) {
              if (selected) {
                onFilterChanged(filter['key'] as String);
              }
            },
            selectedColor:
                isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            backgroundColor: isDark
                ? AppTheme.surfaceVariantDark
                : AppTheme.surfaceVariantLight,
            side: BorderSide(
              color: isSelected
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}
