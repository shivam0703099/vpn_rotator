import 'package:flutter/material.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/vpn_setup_screen/vpn_setup_screen.dart';
import '../presentation/connection_logs_screen/connection_logs_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/server_selection_screen/server_selection_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String settings = '/settings-screen';
  static const String vpnSetup = '/vpn-setup-screen';
  static const String connectionLogs = '/connection-logs-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String serverSelection = '/server-selection-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingFlow(),
    dashboard: (context) => const DashboardScreen(),
    settings: (context) => const SettingsScreen(),
    vpnSetup: (context) => const VpnSetupScreen(),
    connectionLogs: (context) => const ConnectionLogsScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    serverSelection: (context) => const ServerSelectionScreen(),
    // TODO: Add your other routes here
  };
}
