import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'breathing_config.dart';

const int _phaseMs = kPhaseSeconds * 1000;

/// الحالة: كائن غير قابل للتعديل (immutable). أي تغيير ينشئ نسخة جديدة بـ copyWith.
class BreathingState {
  const BreathingState({
    this.phase = BreathPhase.inhale,
    this.elapsedMs = 0, // الزمن المنقضي داخل المرحلة الحالية
    this.cycle = 1,
    this.paused = false,
    this.finished = false,
  });

  final BreathPhase phase;
  final int elapsedMs;
  final int cycle;
  final bool paused;
  final bool finished;

  /// الثواني المتبقية في المرحلة (الرقم داخل الدائرة)
  int get secondsLeft =>
      ((_phaseMs - elapsedMs) / 1000).ceil().clamp(1, kPhaseSeconds).toInt();

  /// حجم الدائرة من 0 إلى 1 (تكبر مع الشهيق، تثبت مع الحبس، تصغر مع الزفير)
  double get progress {
    if (finished) return 0;
    final f = elapsedMs / _phaseMs;
    final raw = switch (phase) {
      BreathPhase.inhale => f,
      BreathPhase.hold => 1.0,
      BreathPhase.exhale => 1 - f,
    };
    return Curves.easeInOut.transform(raw);
  }

  BreathingState copyWith({
    BreathPhase? phase,
    int? elapsedMs,
    int? cycle,
    bool? paused,
    bool? finished,
  }) {
    return BreathingState(
      phase: phase ?? this.phase,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      cycle: cycle ?? this.cycle,
      paused: paused ?? this.paused,
      finished: finished ?? this.finished,
    );
  }
}

/// Riverpod 2.x Notifier: المنطق هنا، والواجهة فقط تراقب `state`.
class BreathingNotifier extends AutoDisposeNotifier<BreathingState> {
  Timer? _timer; // مؤقت التمرين

  // ---------------- دورة حياة الـ Notifier ----------------

  /// build() يعادل initState(): تُستدعى عند أول قراءة للـ Provider
  @override
  BreathingState build() {
    debugPrint('build() -> تجهيز الحالة وبدء المؤقت');

    // ref.onDispose يعادل dispose(): تُستدعى عندما لا يبقى أحد يراقب الـ Provider
    // (autoDispose) أي بعد الرجوع من الشاشة.
    ref.onDispose(() {
      debugPrint('onDispose() -> إلغاء المؤقت');
      _timer?.cancel(); // إيقاف المؤقت لمنع تسريب الذاكرة
      _timer = null;
    });

    _startTimer(); // التمرين يبدأ تلقائياً عند فتح الشاشة
    return const BreathingState();
  }

  // ---------------- منطق التمرين ----------------

  void _startTimer() {
    _timer?.cancel(); // نتأكد أنه لا يوجد مؤقت قديم
    _timer = Timer.periodic(const Duration(milliseconds: kTickMs), _onTick);
  }

  void _onTick(Timer timer) {
    if (state.paused || state.finished) return;
    final elapsed = state.elapsedMs + kTickMs;
    if (elapsed >= _phaseMs) {
      _nextPhase();
    } else {
      state = state.copyWith(elapsedMs: elapsed);
    }
  }

  void _nextPhase() {
    switch (state.phase) {
      case BreathPhase.inhale:
        state = state.copyWith(phase: BreathPhase.hold, elapsedMs: 0);
        break;
      case BreathPhase.hold:
        state = state.copyWith(phase: BreathPhase.exhale, elapsedMs: 0);
        break;
      case BreathPhase.exhale:
        if (state.cycle >= kTotalCycles) {
          _finish();
        } else {
          state = state.copyWith(
              phase: BreathPhase.inhale, elapsedMs: 0, cycle: state.cycle + 1);
        }
        break;
    }
  }

  void _finish() {
    state = state.copyWith(finished: true, elapsedMs: 0);
    _timer?.cancel();
    _timer = null;
    debugPrint('انتهى التمرين وتم إيقاف المؤقت');
  }

  // ---------------- أوامر الواجهة ----------------

  void togglePause() => state = state.copyWith(paused: !state.paused);

  void restart() {
    state = const BreathingState();
    _startTimer();
  }
}

/// autoDispose: الحالة والمؤقت يُحذفان تلقائياً عند مغادرة الشاشة
final breathingProvider =
    NotifierProvider.autoDispose<BreathingNotifier, BreathingState>(
  BreathingNotifier.new,
);
