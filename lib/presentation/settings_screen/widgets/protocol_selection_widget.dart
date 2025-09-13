import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProtocolSelectionWidget extends StatelessWidget {
  final String selectedProtocol;
  final ValueChanged<String> onProtocolChanged;

  const ProtocolSelectionWidget({
    Key? key,
    required this.selectedProtocol,
    required this.onProtocolChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final protocols = ['OpenVPN', 'IKEv2', 'WireGuard'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VPN Protocol',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...protocols.asMap().entries.map((entry) {
            final index = entry.key;
            final protocol = entry.value;
            final isSelected = protocol == selectedProtocol;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onProtocolChanged(protocol),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  child: Row(
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 2.5.w,
                                  height: 2.5.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              protocol,
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _getProtocolDescription(protocol),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getProtocolDescription(String protocol) {
    switch (protocol) {
      case 'OpenVPN':
        return 'Most compatible, good security';
      case 'IKEv2':
        return 'Fast reconnection, mobile optimized';
      case 'WireGuard':
        return 'Modern, fastest performance';
      default:
        return '';
    }
  }
}
