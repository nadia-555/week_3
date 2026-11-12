import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';
import 'breathing_controller.dart';
import 'breathing_screen.dart';
import 'home_screen.dart';

void main() => runApp(const BreathingApp());

class BreathingApp extends StatelessWidget {
  const BreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      home: HomeScreen(
        // الـ Binding يربط الـ Controller بالشاشة: ينشأ عند الدخول
        // ويُحذف (onClose) تلقائياً عند الرجوع منها.
        onStart: () => Get.to(
          () => const BreathingScreen(),
          binding: BindingsBuilder(() {
            Get.put(BreathingController());
          }),
        ),
      ),
    );
  }
}
