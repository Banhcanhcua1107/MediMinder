import 'package:flutter/material.dart';
import 'config/routes.dart' as routes;

class MediMinderApp extends StatelessWidget {
  const MediMinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMinder',
      debugShowCheckedModeBanner: false,
      initialRoute: routes.RouteNames.welcome,
      routes: routes.appRoutes,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D6EF6),
        scaffoldBackgroundColor: Colors.white, // nền trắng cho toàn app
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D6EF6)),
        useMaterial3: true,
        textTheme: Typography.material2021().black.apply(fontFamily: 'Roboto'),
      ),
    );
  }
}
