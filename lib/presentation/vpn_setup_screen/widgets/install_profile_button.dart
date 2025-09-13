import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InstallProfileButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const InstallProfileButton({
    super.key,
    required this.isEnabled,
    this.onPressed,
  });

  @override
  State<InstallProfileButton> createState() => _InstallProfileButtonState();
}

class _InstallProfileButtonState extends State<InstallProfileButton>
    with SingleTickerProviderStateMixin {
  bool _isInstalling = false;
  bool _isCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleInstallation() async {
    if (!widget.isEnabled || _isInstalling || _isCompleted) return;

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _isInstalling = true;
    });

    try {
      // Simulate VPN profile installation process
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isInstalling = false;
        _isCompleted = true;
      });

      // Trigger haptic feedback on success
      if (!kIsWeb) {
        // HapticFeedback.lightImpact();
      }

      widget.onPressed?.call();
    } catch (e) {
      setState(() {
        _isInstalling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed: widget.isEnabled ? _handleInstallation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCompleted
                      ? Colors.green
                      : AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme
                      .lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  elevation: widget.isEnabled ? 2 : 0,
                  shadowColor: AppTheme.lightTheme.colorScheme.shadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _buildButtonContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_isCompleted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 2.w),
          Text(
            'VPN Profile Installed',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (_isInstalling) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'Installing VPN Profile...',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'shield',
          color: widget.isEnabled
              ? Colors.white
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 24,
        ),
        SizedBox(width: 2.w),
        Text(
          'Install VPN Profile',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: widget.isEnabled
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
