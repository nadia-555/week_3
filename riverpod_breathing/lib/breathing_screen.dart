import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';
import 'breathing_config.dart';
import 'breathing_notifier.dart';

/// شاشة التمرين. مقسمة إلى ConsumerWidget صغيرة؛ كل واحدة تراقب
/// الجزء الذي تحتاجه فقط (select) فلا تُعاد بناء الشاشة كاملة.
class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              _Header(),
              SizedBox(height: 32),
              _PhaseTitle(),
              SizedBox(height: 32),
              _BreathingCircle(),
              SizedBox(height: 32),
              _PhaseBars(),
              Spacer(),
              _Buttons(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = ref.watch(breathingProvider.select((s) => s.cycle));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('تمرين التنفس',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('الدورة $cycle من $kTotalCycles',
            style: const TextStyle(fontSize: 15, color: AppColors.muted)),
      ],
    );
  }
}

class _PhaseTitle extends ConsumerWidget {
  const _PhaseTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(breathingProvider.select((s) => s.phase));
    final finished = ref.watch(breathingProvider.select((s) => s.finished));
    return Column(
      children: [
        Text(finished ? 'أحسنت' : phase.label,
            style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.accent)),
        const SizedBox(height: 6),
        Text(finished ? 'أكملت $kTotalCycles دورات من التنفس' : phase.hint,
            style: const TextStyle(fontSize: 16, color: AppColors.muted)),
      ],
    );
  }
}

class _BreathingCircle extends ConsumerWidget {
  const _BreathingCircle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(breathingProvider.select((s) => s.progress));
    final secondsLeft = ref.watch(breathingProvider.select((s) => s.secondsLeft));
    final finished = ref.watch(breathingProvider.select((s) => s.finished));

    final inner = 130 + 100 * t; // من 130 إلى 230
    final mid = inner + 40;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
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
          finished
              ? const Icon(Icons.check, size: 80, color: AppColors.bg)
              : Text('$secondsLeft',
                  style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bg)),
        ],
      ),
    );
  }
}

class _PhaseBars extends ConsumerWidget {
  const _PhaseBars();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(breathingProvider.select((s) => s.phase));
    final finished = ref.watch(breathingProvider.select((s) => s.finished));

    return Row(
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
                      color: (p == phase && !finished)
                          ? AppColors.accent
                          : AppColors.ring,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${p.label} $kPhaseSeconds',
                      style: TextStyle(
                          fontSize: 14,
                          color: (p == phase && !finished)
                              ? AppColors.text
                              : AppColors.muted)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Buttons extends ConsumerWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finished = ref.watch(breathingProvider.select((s) => s.finished));
    final paused = ref.watch(breathingProvider.select((s) => s.paused));
    // read: للحصول على الـ Notifier واستدعاء دوالّه فقط (بدون مراقبة)
    final notifier = ref.read(breathingProvider.notifier);

    final label = finished ? 'إعادة' : (paused ? 'استئناف' : 'إيقاف مؤقت');

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.bg,
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
            ),
            onPressed: finished ? notifier.restart : notifier.togglePause,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
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
            // الرجوع للشاشة السابقة => الـ Provider يُحذف => onDispose()
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إنهاء', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
