import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/course_service.dart';
import '../../courses/models/course_model.dart';
import '../models/progress_model.dart';
import '../utils/performance.dart';

class AnalyticsScreen extends StatelessWidget {
  final String courseId;
  const AnalyticsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analitika'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<List<ProgressModel>>(
        stream: courseService.watchCourseProgress(courseId),
        builder: (context, progressSnap) {
          return FutureBuilder<List<CourseModel>>(
            future: courseService.watchAllCourses().first,
            builder: (context, courseSnap) {
              final progresses = progressSnap.data ?? [];
              final course = courseSnap.data
                  ?.where((c) => c.id == courseId)
                  .firstOrNull;

              if (progressSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final totalLessons = course?.totalLessons ?? 1;

              if (progresses.isEmpty) {
                return const _EmptyAnalytics();
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  if (course != null) ...[
                    _CourseHeader(course: course),
                    const SizedBox(height: 20),
                  ],
                  _SummaryCards(
                    progresses: progresses,
                    totalLessons: totalLessons,
                  ),
                  const SizedBox(height: 20),
                  _LowAchieversSection(
                    progresses: progresses,
                    totalLessons: totalLessons,
                  ),
                  _ActivityTrendChart(progresses: progresses),
                  const SizedBox(height: 20),
                  _StudentProgressList(
                    progresses: progresses,
                    totalLessons: totalLessons,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  final CourseModel course;
  const _CourseHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.tinted(AppColors.primary),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.totalLessons} dars · ${course.teacherName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final List<ProgressModel> progresses;
  final int totalLessons;

  const _SummaryCards({required this.progresses, required this.totalLessons});

  @override
  Widget build(BuildContext context) {
    final avgCompletion =
        progresses
            .map((p) => p.completionPercent(totalLessons))
            .fold(0.0, (a, b) => a + b) /
        progresses.length;
    final finished = progresses
        .where((p) => p.completedLessons >= totalLessons)
        .length;
    final atRisk = progresses.where((p) {
      final daysSinceActivity = DateTime.now()
          .difference(p.lastActiveAt)
          .inDays;
      return daysSinceActivity >= 5 || p.completedLessons == 0;
    }).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Talabalar',
                value: '${progresses.length}',
                icon: Icons.people_rounded,
                color: AppColors.primary,
                bg: AppColors.primarySoft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'O\'rtacha',
                value: '${avgCompletion.toStringAsFixed(0)}%',
                icon: Icons.trending_up_rounded,
                color: AppColors.secondary,
                bg: AppColors.secondarySoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Tugatdi',
                value: '$finished',
                icon: Icons.workspace_premium_rounded,
                color: AppColors.accent,
                bg: AppColors.accentSoft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Xavfda',
                value: '$atRisk',
                icon: Icons.warning_amber_rounded,
                color: AppColors.error,
                bg: AppColors.errorSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

enum TrendPeriod { weekly, monthly, yearly }

extension on TrendPeriod {
  String get label => switch (this) {
    TrendPeriod.weekly => 'Haftalik',
    TrendPeriod.monthly => 'Oylik',
    TrendPeriod.yearly => 'Yillik',
  };

  String get subtitle => switch (this) {
    TrendPeriod.weekly => 'Oxirgi 7 kun ichida tugatilgan darslar',
    TrendPeriod.monthly => 'Oxirgi 4 hafta ichida tugatilgan darslar',
    TrendPeriod.yearly => 'Oxirgi 12 oy ichida tugatilgan darslar',
  };
}

class _ActivityTrendChart extends StatefulWidget {
  final List<ProgressModel> progresses;
  const _ActivityTrendChart({required this.progresses});

  @override
  State<_ActivityTrendChart> createState() => _ActivityTrendChartState();
}

class _ActivityTrendChartState extends State<_ActivityTrendChart> {
  TrendPeriod _period = TrendPeriod.weekly;

  static const _months = [
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'Iyn',
    'Iyl',
    'Avg',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];
  static const _days = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];

  /// Tanlangan davr bo'yicha (yorliq, son) ustunlarini hisoblaydi.
  List<({String label, int count})> _buckets() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_period) {
      case TrendPeriod.weekly:
        final counts = List<int>.filled(7, 0);
        final labels = [
          for (var i = 6; i >= 0; i--)
            _days[(today.subtract(Duration(days: i)).weekday - 1) % 7],
        ];
        for (final d in _completedDays()) {
          final diff = today.difference(d).inDays;
          if (diff >= 0 && diff < 7) counts[6 - diff]++;
        }
        return [
          for (var i = 0; i < 7; i++) (label: labels[i], count: counts[i]),
        ];

      case TrendPeriod.monthly:
        // Oxirgi 4 hafta, har biri bir ustun.
        final counts = List<int>.filled(4, 0);
        for (final d in _completedDays()) {
          final diff = today.difference(d).inDays;
          if (diff >= 0 && diff < 28) counts[3 - (diff ~/ 7)]++;
        }
        const labels = ['4-hafta', '3-hafta', '2-hafta', 'Bu hafta'];
        return [
          for (var i = 0; i < 4; i++) (label: labels[i], count: counts[i]),
        ];

      case TrendPeriod.yearly:
        // Oxirgi 12 oy, har biri bir ustun.
        final counts = List<int>.filled(12, 0);
        final labels = [
          for (var i = 11; i >= 0; i--)
            _months[DateTime(now.year, now.month - i, 1).month - 1],
        ];
        for (final d in _completedDays()) {
          final monthsAgo = (now.year - d.year) * 12 + (now.month - d.month);
          if (monthsAgo >= 0 && monthsAgo < 12) counts[11 - monthsAgo]++;
        }
        return [
          for (var i = 0; i < 12; i++) (label: labels[i], count: counts[i]),
        ];
    }
  }

  Iterable<DateTime> _completedDays() sync* {
    for (final p in widget.progresses) {
      for (final lp in p.lessonProgresses) {
        final c = lp.completedAt;
        if (c == null) continue;
        yield DateTime(c.year, c.month, c.day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buckets = _buckets();
    final maxCount = buckets.fold<int>(0, (a, b) => a > b.count ? a : b.count);
    final maxY = maxCount.clamp(4, 100000).toDouble();
    // Yillik ko'rinishda yorliqlar zich — har bittasini ko'rsatamiz.
    final showAllLabels = _period != TrendPeriod.yearly;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_period.label} faollik',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _period.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PeriodToggle(
            selected: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY + 1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 4).clamp(1, 100000),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 1,
                      getTitlesWidget: (val, _) {
                        // Faqat butun nuqtalarda yorliq chizamiz —
                        // aks holda kunlar takror yoziladi.
                        if (val != val.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        final i = val.toInt();
                        if (i < 0 || i >= buckets.length) {
                          return const SizedBox.shrink();
                        }
                        if (!showAllLabels && i.isOdd) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            buckets[i].label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toInt()} dars',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < buckets.length; i++)
                        FlSpot(i.toDouble(), buckets[i].count.toDouble()),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final TrendPeriod selected;
  final ValueChanged<TrendPeriod> onChanged;
  const _PeriodToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (final p in TrendPeriod.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected == p
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: selected == p ? AppShadows.sm : null,
                  ),
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected == p
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LowAchieversSection extends StatelessWidget {
  final List<ProgressModel> progresses;
  final int totalLessons;

  const _LowAchieversSection({
    required this.progresses,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final low = progresses.where((p) => p.isLowAchiever(totalLessons)).toList()
      ..sort(
        (a, b) => a
            .performanceScore(totalLessons)
            .compareTo(b.performanceScore(totalLessons)),
      );

    if (low.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'O\'zlashtirishi past',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${low.length} o\'quvchi e\'tiboringizni talab qiladi',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.error.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...low.map((p) {
              final pct = p.completionPercent(totalLessons);
              final avg = p.averageScore;
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => _showStudentDetail(context, p, totalLessons),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.error.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              p.studentName.isEmpty
                                  ? '?'
                                  : p.studentName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  avg > 0
                                      ? 'Tugatish ${pct.toStringAsFixed(0)}% · O\'rtacha ball ${avg.toStringAsFixed(0)}'
                                      : 'Tugatish ${pct.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StudentProgressList extends StatelessWidget {
  final List<ProgressModel> progresses;
  final int totalLessons;

  const _StudentProgressList({
    required this.progresses,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<ProgressModel>.from(progresses)
      ..sort(
        (a, b) => b
            .completionPercent(totalLessons)
            .compareTo(a.completionPercent(totalLessons)),
      );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Talabalar reytingi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final pct = p.completionPercent(totalLessons);
            return Column(
              children: [
                InkWell(
                  onTap: () => _showStudentDetail(context, p, totalLessons),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        _RankBadge(rank: i + 1),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  backgroundColor: AppColors.surfaceMuted,
                                  color: pct >= 75
                                      ? AppColors.secondary
                                      : pct >= 25
                                      ? AppColors.primary
                                      : AppColors.accent,
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < sorted.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}

void _showStudentDetail(
  BuildContext context,
  ProgressModel p,
  int totalLessons,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _StudentDetailSheet(progress: p, totalLessons: totalLessons),
  );
}

class _StudentDetailSheet extends StatelessWidget {
  final ProgressModel progress;
  final int totalLessons;
  const _StudentDetailSheet({
    required this.progress,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final pct = p.completionPercent(totalLessons);
    final avg = p.averageScore;
    final isLow = p.isLowAchiever(totalLessons);
    final accent = isLow ? AppColors.error : AppColors.primary;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: accent.withValues(alpha: 0.12),
                child: Text(
                  p.studentName.isEmpty ? '?' : p.studentName[0].toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLow ? 'O\'zlashtirishi past' : 'O\'quvchi faolligi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLow
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Tugatish',
                  value: '${pct.toStringAsFixed(0)}%',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Darslar',
                  value: '${p.completedLessons}/$totalLessons',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'O\'rtacha ball',
                  value: avg > 0 ? avg.toStringAsFixed(0) : '—',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ActivityTrendChart(progresses: [p]),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isMedal = rank <= 3;
    final colors = const [
      Color(0xFFFFC700),
      Color(0xFF94A3B8),
      Color(0xFFCD7F32),
    ];
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isMedal
            ? LinearGradient(
                colors: [
                  colors[rank - 1],
                  colors[rank - 1].withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isMedal ? null : AppColors.surfaceMuted,
        shape: BoxShape.circle,
        boxShadow: isMedal
            ? [
                BoxShadow(
                  color: colors[rank - 1].withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isMedal
            ? const Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: Colors.white,
              )
            : Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hali talaba yo\'q',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Talabalar kursga yozilgach, analitika bu yerda paydo bo\'ladi',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
