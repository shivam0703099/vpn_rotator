import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegionHeaderWidget extends StatelessWidget {
  final String regionName;
  final int serverCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const RegionHeaderWidget({
    Key? key,
    required this.regionName,
    required this.serverCount,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color:
            isDark ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariantLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        regionName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.onSurfaceDark
                                      : AppTheme.onSurfaceLight,
                                ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '$serverCount servers available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppTheme.onSurfaceVariantDark
                                  : AppTheme.onSurfaceVariantLight,
                            ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: isDark
                        ? AppTheme.onSurfaceVariantDark
                        : AppTheme.onSurfaceVariantLight,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
