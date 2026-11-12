import 'package:flutter/material.dart';

import 'app_colors.dart';

/// الشاشة الرئيسية: الدخول للتمرين ثم الرجوع منه يتخلص من الحالة (dispose)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.air, size: 96, color: AppColors.accent),
              const SizedBox(height: 16),
              const Text('تمرين التنفس',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('شهيق - حبس - زفير',
                  style: TextStyle(fontSize: 16, color: AppColors.muted)),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.bg,
                  minimumSize: const Size(220, 56),
                  shape: const StadiumBorder(),
                ),
                onPressed: onStart,
                child: const Text('ابدأ التمرين',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
