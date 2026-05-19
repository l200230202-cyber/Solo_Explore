import 'package:flutter/material.dart';
import '../screens/design_system_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_shell.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/culinary_detail_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/badges_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/trip_plan_detail_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/notifications_screen.dart';

class AppRouter {
  static const String designSystem = '/design-system';
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String destinationDetail = '/destination';
  static const String culinaryDetail = '/culinary';
  static const String eventDetail = '/event';
  static const String search = '/search';
  static const String badges = '/badges';
  static const String rewards = '/rewards';
  static const String tripPlanDetail = '/trip-plan-detail';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case designSystem:
        return MaterialPageRoute(builder: (_) => const DesignSystemScreen());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case destinationDetail:
        final slug = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(slug: slug),
        );
      case culinaryDetail:
        final slug = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CulinaryDetailScreen(slug: slug),
        );
      case eventDetail:
        final slug = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => EventDetailScreen(slug: slug));
      case search:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SearchScreen(initialCategory: args),
          settings: settings,
        );
      case badges:
        return MaterialPageRoute(builder: (_) => const BadgesScreen());
      case rewards:
        return MaterialPageRoute(builder: (_) => const RewardsScreen());
      case tripPlanDetail:
        final planId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => TripPlanDetailScreen(planId: planId),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) =>
              ResetPasswordScreen(token: args['token']!, email: args['email']!),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
