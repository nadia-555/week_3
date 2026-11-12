import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';
import 'breathing_config.dart';
import 'breathing_controller.dart';

/// شاشة التمرين: StatelessWidget لأن الحالة كلها في الـ Controller.
/// GetView يعطينا الوصول للـ Controller عبر `controller`.
class BreathingScreen extends GetView<BreathingController> {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تمرين التنفس',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Obx(() => Text('الدورة ${controller.cycle.value} من $kTotalCycles',
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.muted))),
                ],
              ),
              const SizedBox(height: 32),
              Obx(() => Text(
                  controller.finished.value
                      ? 'أحسنت'
                      : controller.phase.value.label,
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent))),
              const SizedBox(height: 6),
              Obx(() => Text(
                  controller.finished.value
                      ? 'أكملت $kTotalCycles دورات من التنفس'
                      : controller.phase.value.hint,
                  style:
                      const TextStyle(fontSize: 16, color: AppColors.muted))),
              const SizedBox(height: 32),
              _buildCircle(),
              const SizedBox(height: 32),
              _buildPhaseBars(),
              const Spacer(),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircle() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Obx(() {
        final t = controller.progress;
        final inner = 130 + 100 * t; // من 130 إلى 230
        final mid = inner + 40;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ring, width: 2),
              ),
            ),
            Container(
              width: mid,
              height: mid,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.mid),
            ),
            Container(
              width: inner,
              height: inner,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.accent),
            ),
            controller.finished.value
                ? const Icon(Icons.check, size: 80, color: AppColors.bg)
                : Text('${controller.secondsLeft}',
                    style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bg)),
          ],
        );
      }),
    );
  }

  Widget _buildPhaseBars() {
    return Obx(() => Row(
          children: [
            for (final p in BreathPhase.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: _isActive(p) ? AppColors.accent : AppColors.ring,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${p.label} $kPhaseSeconds',
                          style: TextStyle(
                              fontSize: 14,
                              color: _isActive(p)
                                  ? AppColors.text
                                  : AppColors.muted)),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }

  bool _isActive(BreathPhase p) =>
      p == controller.phase.value && !controller.finished.value;

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final finished = controller.finished.value;
            final label =
                finished ? 'إعادة' : (controller.paused.value ? 'استئناف' : 'إيقاف مؤقت');
            return FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.bg,
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
              ),
              onPressed: finished ? controller.restart : controller.togglePause,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.ring, width: 2),
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
            ),
            // الرجوع للشاشة السابقة يستدعي onClose() تلقائياً
            onPressed: () => Get.back(),
            child: const Text('إنهاء', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
