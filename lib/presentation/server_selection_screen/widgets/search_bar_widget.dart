import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color:
            isDark ? AppTheme.surfaceVariantDark : AppTheme.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNode.hasFocus
              ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by country or city...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: (isDark
                        ? AppTheme.onSurfaceVariantDark
                        : AppTheme.onSurfaceVariantLight)
                    .withValues(alpha: 0.6),
              ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: isDark
                  ? AppTheme.onSurfaceVariantDark
                  : AppTheme.onSurfaceVariantLight,
              size: 5.w,
            ),
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onClear();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'clear',
                      color: isDark
                          ? AppTheme.onSurfaceVariantDark
                          : AppTheme.onSurfaceVariantLight,
                      size: 5.w,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
