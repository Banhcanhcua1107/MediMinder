import 'package:flutter/material.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

class RouteNames {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
}

final Map<String, WidgetBuilder> appRoutes = {
  RouteNames.welcome: (context) => const WelcomeScreen(),
  RouteNames.login: (context) => const LoginScreen(),
  RouteNames.register: (context) => const RegisterScreen(),
};
