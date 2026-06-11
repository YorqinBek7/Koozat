import '../models/progress_model.dart';

/// Talaba "o'zlashtirishi past" deb hisoblanishi uchun chegaralar.
class PerformanceThresholds {
  /// Tugatish foizi shu qiymatdan past bo'lsa — past o'zlashtirish.
  static const double lowCompletionPercent = 40;

  /// O'rtacha ball shu qiymatdan past bo'lsa — past o'zlashtirish.
  static const double lowAverageScore = 50;

  /// Shu kundan ko'p faolsiz bo'lsa — xavf ostida.
  static const int inactiveDays = 7;
}

extension PerformanceX on ProgressModel {
  /// Talaba o'zlashtirishi past (kuchsiz)mi?
  /// Tugatish foizi yoki o'rtacha balli chegaradan past bo'lsa — ha.
  bool isLowAchiever(int totalLessons) {
    final pct = completionPercent(totalLessons);
    if (pct < PerformanceThresholds.lowCompletionPercent) return true;
    final avg = averageScore;
    if (avg > 0 && avg < PerformanceThresholds.lowAverageScore) return true;
    return false;
  }

  /// Past o'zlashtirishni saralash uchun og'irlik (kichik = yomonroq).
  /// Tugatish foizi va o'rtacha ballni birlashtiradi.
  double performanceScore(int totalLessons) {
    final pct = completionPercent(totalLessons);
    final avg = averageScore;
    if (avg <= 0) return pct;
    return (pct + avg) / 2;
  }
}
