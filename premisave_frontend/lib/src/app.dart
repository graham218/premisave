import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'theme/app_theme.dart';

class PremisaveApp extends StatelessWidget {
  const PremisaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Premisave',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}