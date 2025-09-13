import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_bottom_widget.dart';
import './widgets/onboarding_page_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  bool _userInteracted = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Privacy Protection",
      "description":
          "Secure your online activities with automated VPN server rotation. Your data stays protected while browsing, streaming, and working online.",
      "iconName": "security",
      "iconColor": AppTheme.lightTheme.colorScheme.primary,
    },
    {
      "title": "Automated Management",
      "description":
          "Set custom rotation schedules and let the app handle server switching automatically. No manual intervention needed for continuous protection.",
      "iconName": "schedule",
      "iconColor": AppTheme.lightTheme.colorScheme.tertiary,
    },
    {
      "title": "Advanced Security",
      "description":
          "Built-in kill switch and leak protection ensure your real IP never gets exposed. Monitor connection status and performance in real-time.",
      "iconName": "shield",
      "iconColor": AppTheme.lightTheme.colorScheme.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_userInteracted && mounted) {
        if (_currentPage < _onboardingData.length - 1) {
          _nextPage();
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _onUserInteraction() {
    if (!_userInteracted) {
      setState(() {
        _userInteracted = true;
      });
      _autoAdvanceTimer?.cancel();
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _onUserInteraction();
    Navigator.pushReplacementNamed(context, '/vpn-setup-screen');
  }

  void _getStarted() {
    _onUserInteraction();
    Navigator.pushReplacementNamed(context, '/vpn-setup-screen');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Haptic feedback for page changes
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: _onUserInteraction,
        onPanStart: (_) => _onUserInteraction(),
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPageWidget(
                    title: data["title"] as String,
                    description: data["description"] as String,
                    iconName: data["iconName"] as String,
                    iconColor: data["iconColor"] as Color,
                  );
                },
              ),
            ),

            // Bottom navigation area
            OnboardingBottomWidget(
              currentPage: _currentPage,
              totalPages: _onboardingData.length,
              onNext: () {
                _onUserInteraction();
                _nextPage();
              },
              onSkip: _skipOnboarding,
              onGetStarted: _getStarted,
            ),
          ],
        ),
      ),
    );
  }
}
