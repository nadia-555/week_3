import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';
import 'breathing_screen.dart';
import 'home_screen.dart';

// ProviderScope هو المكان الذي تُحفظ فيه حالة كل الـ Providers
void main() => runApp(const ProviderScope(child: BreathingApp()));

class BreathingApp extends StatelessWidget {
  const BreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تمرين التنفس',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorSchemeSeed: AppColors.accent,
      ),
      // اتجاه الواجهة من اليمين لليسار
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: Builder(
        builder: (context) => HomeScreen(
          onStart: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BreathingScreen()),
          ),
        ),
      ),
    );
  }
}
