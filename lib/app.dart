import 'package:flutter/material.dart';
import 'config/routes.dart' as routes;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/language_provider.dart';

class MediMinderApp extends StatelessWidget {
  final String? initialRoute;

  const MediMinderApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'MediMinder',
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute ?? routes.RouteNames.welcome,
          routes: routes.appRoutes,
          onGenerateRoute: routes.generateRoute,
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            primaryColor: const Color(0xFF196EB0),
            scaffoldBackgroundColor: Colors.white, // nền trắng cho toàn app
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF196EB0),
            ),
            useMaterial3: true,
            textTheme: Typography.material2021().black.apply(
              fontFamily: 'Roboto',
            ),
          ),
        );
      },
    );
  }
}
