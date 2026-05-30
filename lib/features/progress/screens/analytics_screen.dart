import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/course_service.dart';
import '../../courses/models/course_model.dart';
import '../models/progress_model.dart';

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
              final course =
                  courseSnap.data?.where((c) => c.id == courseId).firstOrNull;

              if (progressSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (progresses.isEmpty) {
                return const _EmptyAnalytics();
              }

              final totalLessons = course?.totalLessons ?? 1;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  if (course != null) ...[
                    _CourseHeader(course: course),
                    const SizedBox(height: 20),
                  ],
                  _SummaryCards(
                      progresses: progresses, totalLessons: totalLessons),
                  const SizedBox(height: 20),
                  _WeeklyTrendChart(progresses: progresses),
                  const SizedBox(height: 20),
                  _ProgressBarChart(
                      progresses: progresses, totalLessons: totalLessons),
                  const SizedBox(height: 20),
                  _StudentProgressList(
                      progresses: progresses, totalLessons: totalLessons),
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

  const _SummaryCards(
      {required this.progresses, required this.totalLessons});

  @override
  Widget build(BuildContext context) {
    final avgCompletion = progresses
            .map((p) => p.completionPercent(totalLessons))
            .fold(0.0, (a, b) => a + b) /
        progresses.length;
    final finished =
        progresses.where((p) => p.completedLessons >= totalLessons).length;
    final atRisk = progresses.where((p) {
      final daysSinceActivity =
          DateTime.now().difference(p.lastActiveAt).inDays;
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

class _WeeklyTrendChart extends StatelessWidget {
  final List<ProgressModel> progresses;
  const _WeeklyTrendChart({required this.progresses});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dailyCounts = List<int>.filled(7, 0);
    final labels = <String>[];

    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      labels.add(_dayLabel(day.weekday));
    }

    for (final p in progresses) {
      for (final lp in p.lessonProgresses) {
        if (lp.completedAt == null) continue;
        final completedDay = DateTime(
            lp.completedAt!.year, lp.completedAt!.month, lp.completedAt!.day);
        final diff = today.difference(completedDay).inDays;
        if (diff >= 0 && diff < 7) {
          dailyCounts[6 - diff]++;
        }
      }
    }

    final maxY = (dailyCounts.fold<int>(0, (a, b) => a > b ? a : b))
        .clamp(4, 1000)
        .toDouble();

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
                child: const Icon(Icons.show_chart_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haftalik faollik',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Oxirgi 7 kun ichida tugatilgan darslar',
                      style: TextStyle(
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
                  horizontalInterval: (maxY / 4).clamp(1, 1000),
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
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[i],
                            style: const TextStyle(
                              fontSize: 11,
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
                    spots: List.generate(
                      7,
                      (i) => FlSpot(i.toDouble(), dailyCounts[i].toDouble()),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, _, __, ___) =>
                          FlDotCirclePainter(
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

  String _dayLabel(int weekday) {
    const labels = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];
    return labels[(weekday - 1) % 7];
  }
}

class _ProgressBarChart extends StatelessWidget {
  final List<ProgressModel> progresses;
  final int totalLessons;

  const _ProgressBarChart(
      {required this.progresses, required this.totalLessons});

  @override
  Widget build(BuildContext context) {
    final groups = [0, 0, 0, 0];
    for (final p in progresses) {
      final pct = p.completionPercent(totalLessons);
      if (pct <= 25) {
        groups[0]++;
      } else if (pct <= 50) {
        groups[1]++;
      } else if (pct <= 75) {
        groups[2]++;
      } else {
        groups[3]++;
      }
    }

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
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress taqsimoti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Talabalarning bajarish darajasi bo\'yicha',
                      style: TextStyle(
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
          const SizedBox(height: 22),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (progresses.length + 1).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
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
                      getTitlesWidget: (val, _) {
                        const labels = [
                          '0-25%',
                          '26-50%',
                          '51-75%',
                          '76-100%'
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[val.toInt()],
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
                barGroups: List.generate(
                  4,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: groups[i].toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            [
                              AppColors.error,
                              AppColors.accent,
                              AppColors.primaryLight,
                              AppColors.secondary,
                            ][i],
                            [
                              AppColors.error,
                              AppColors.accent,
                              AppColors.primaryLight,
                              AppColors.secondary,
                            ][i]
                                .withValues(alpha: 0.7),
                          ],
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
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

class _StudentProgressList extends StatelessWidget {
  final List<ProgressModel> progresses;
  final int totalLessons;

  const _StudentProgressList(
      {required this.progresses, required this.totalLessons});

  @override
  Widget build(BuildContext context) {
    final sorted = List<ProgressModel>.from(progresses)
      ..sort((a, b) => b
          .completionPercent(totalLessons)
          .compareTo(a.completionPercent(totalLessons)));

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
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.accent, size: 20),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
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
                    ],
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
            ? const Icon(Icons.emoji_events_rounded,
                size: 16, color: Colors.white)
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
