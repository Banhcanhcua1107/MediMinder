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
      onGenerateRoute: routes.generateRoute,
      theme: ThemeData(
        primaryColor: const Color(0xFF196EB0),
        scaffoldBackgroundColor: Colors.white, // nền trắng cho toàn app
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF196EB0)),
        useMaterial3: true,
        textTheme: Typography.material2021().black.apply(fontFamily: 'Roboto'),
      ),
    );
  }
}
