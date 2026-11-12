/// عدد الدورات
const int kTotalCycles = 6;

/// مدة كل مرحلة بالثواني
const int kPhaseSeconds = 4;

/// كل كم ميلي ثانية يتحدث المؤقت (لتحريك الدائرة بسلاسة)
const int kTickMs = 50;

enum BreathPhase { inhale, hold, exhale }

extension BreathPhaseText on BreathPhase {
  String get label {
    switch (this) {
      case BreathPhase.inhale:
        return 'شهيق';
      case BreathPhase.hold:
        return 'حبس';
      case BreathPhase.exhale:
        return 'زفير';
    }
  }

  String get hint {
    switch (this) {
      case BreathPhase.inhale:
        return 'املأ صدرك بالهواء ببطء';
      case BreathPhase.hold:
        return 'ثبّت نفسك بهدوء';
      case BreathPhase.exhale:
        return 'أخرج الهواء ببطء';
    }
  }
}
