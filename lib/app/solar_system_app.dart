import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'app_theme.dart';
import '../screens/intro_screen.dart';

class SolarSystemApp extends StatelessWidget {
  const SolarSystemApp({super.key, this.enableIntro = false});

  final bool enableIntro;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar System Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: IntroScreen(enabled: enableIntro, destination: const AppShell()),
    );
  }
}
