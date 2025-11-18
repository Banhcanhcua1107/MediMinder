import 'package:flutter/material.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/auth/create_new_password_screen.dart';
import '../screens/auth/password_changed_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_med_screen.dart';

class RouteNames {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verification = '/verification';
  static const String createNewPassword = '/create-new-password';
  static const String passwordChanged = '/password-changed';
  static const String home = '/home';
  static const String addMed = '/add-med';
  static const String profile = '/profile';
}

final Map<String, WidgetBuilder> appRoutes = {
  RouteNames.welcome: (context) => const WelcomeScreen(),
  RouteNames.login: (context) => const LoginScreen(),
  RouteNames.register: (context) => const RegisterScreen(),
  RouteNames.forgotPassword: (context) => const ForgotPasswordScreen(),
  RouteNames.passwordChanged: (context) => const PasswordChangedScreen(),
  RouteNames.home: (context) => const DashboardScreen(),
  RouteNames.addMed: (context) => const AddMedScreen(),
  RouteNames.profile: (context) => const DashboardScreen(),
};

// Route generator for routes with arguments
Route<dynamic> Function(RouteSettings)
generateRoute = (RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.home:
      return MaterialPageRoute(builder: (context) => const DashboardScreen());
    case RouteNames.addMed:
      return MaterialPageRoute(builder: (context) => const AddMedScreen());
    case RouteNames.profile:
      return MaterialPageRoute(builder: (context) => const DashboardScreen());
    case RouteNames.resetPassword:
      final email = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(email: email ?? ''),
      );
    case RouteNames.verification:
      final email = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (context) => VerificationScreen(email: email ?? ''),
      );
    case RouteNames.createNewPassword:
      final email = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (context) => CreateNewPasswordScreen(email: email ?? ''),
      );
    default:
      return MaterialPageRoute(builder: (context) => const WelcomeScreen());
  }
};
