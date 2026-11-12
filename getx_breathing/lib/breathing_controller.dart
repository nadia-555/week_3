import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'breathing_config.dart';

/// كل الحالة والمنطق هنا. الواجهة فقط تقرأ المتغيرات داخل Obx وتستدعي الدوال.
class BreathingController extends GetxController {
  // ---------------- الحالة (Rx) ----------------
  final phase = BreathPhase.inhale.obs;
  final elapsedMs = 0.obs; // الزمن المنقضي داخل المرحلة الحالية
  final cycle = 1.obs;
  final paused = false.obs;
  final finished = false.obs;

  Timer? _timer; // مؤقت التمرين

  static const int _phaseMs = kPhaseSeconds * 1000;

  // ---------------- قيم مشتقة ----------------

  /// الثواني المتبقية في المرحلة (الرقم داخل الدائرة)
  int get secondsLeft =>
      ((_phaseMs - elapsedMs.value) / 1000).ceil().clamp(1, kPhaseSeconds).toInt();

  /// حجم الدائرة من 0 إلى 1 (تكبر مع الشهيق، تثبت مع الحبس، تصغر مع الزفير)
  double get progress {
    if (finished.value) return 0;
    final f = elapsedMs.value / _phaseMs;
    final raw = switch (phase.value) {
      BreathPhase.inhale => f,
      BreathPhase.hold => 1.0,
      BreathPhase.exhale => 1 - f,
    };
    return Curves.easeInOut.transform(raw);
  }

  // ---------------- دورة حياة الـ Controller ----------------

  /// يعادل initState()
  @override
  void onInit() {
    super.onInit();
    debugPrint('onInit() -> تجهيز الحالة وبدء المؤقت');
    _startSession(); // التمرين يبدأ تلقائياً عند فتح الشاشة
  }

  /// يعادل dispose()
  @override
  void onClose() {
    debugPrint('onClose() -> إلغاء المؤقت');
    _timer?.cancel(); // إيقاف المؤقت لمنع تسريب الذاكرة
    _timer = null;
    super.onClose();
  }

  // ---------------- منطق التمرين ----------------

  void _startSession() {
    phase.value = BreathPhase.inhale;
    elapsedMs.value = 0;
    cycle.value = 1;
    paused.value = false;
    finished.value = false;
    _timer?.cancel(); // نتأكد أنه لا يوجد مؤقت قديم
    _timer = Timer.periodic(const Duration(milliseconds: kTickMs), _onTick);
  }

  void _onTick(Timer timer) {
    if (paused.value || finished.value) return;
    elapsedMs.value += kTickMs;
    if (elapsedMs.value >= _phaseMs) _nextPhase();
  }

  void _nextPhase() {
    elapsedMs.value = 0;
    switch (phase.value) {
      case BreathPhase.inhale:
        phase.value = BreathPhase.hold;
        break;
      case BreathPhase.hold:
        phase.value = BreathPhase.exhale;
        break;
      case BreathPhase.exhale:
        if (cycle.value >= kTotalCycles) {
          _finish();
        } else {
          cycle.value++;
          phase.value = BreathPhase.inhale;
        }
        break;
    }
  }

  void _finish() {
    finished.value = true;
    _timer?.cancel();
    _timer = null;
    debugPrint('انتهى التمرين وتم إيقاف المؤقت');
  }

  // ---------------- أوامر الواجهة ----------------

  void togglePause() => paused.value = !paused.value;

  void restart() => _startSession();
}
