import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/courses/models/course_model.dart';
import '../../../features/progress/models/progress_model.dart';
import '../../../features/progress/utils/performance.dart';
import '../../../shared/services/course_service.dart';

/// O'qituvchining asosiy ekranida o'zlashtirishi past o'quvchilarni
/// ajratib ko'rsatadi. Barcha kurslar bo'yicha Firestore'dan o'qiydi.
class LowPerformersCard extends StatefulWidget {
  final List<CourseModel> courses;
  const LowPerformersCard({super.key, required this.courses});

  @override
  State<LowPerformersCard> createState() => _LowPerformersCardState();
}

class _LowPerformersCardState extends State<LowPerformersCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    final courses = widget.courses;
    final courseIds = courses.map((c) => c.id).toList();
    final lessonsByCourse = {for (final c in courses) c.id: c.totalLessons};
    final titleByCourse = {for (final c in courses) c.id: c.title};

    if (courseIds.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<ProgressModel>>(
      stream: courseService.watchProgressForCourses(courseIds),
      builder: (context, snapshot) {
        final progresses = snapshot.data ?? [];
        final low = progresses
            .where((p) =>
                p.isLowAchiever(lessonsByCourse[p.courseId] ?? 1))
            .toList()
          ..sort((a, b) => a
              .performanceScore(lessonsByCourse[a.courseId] ?? 1)
              .compareTo(b.performanceScore(lessonsByCourse[b.courseId] ?? 1)));

        if (low.isEmpty) return const SizedBox.shrink();

        final shown = _expanded ? low : low.take(4).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.errorSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                      ),
                      child: const Icon(Icons.priority_high_rounded,
                          color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'O\'zlashtirishi past o\'quvchilar',
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
              ...shown.map((p) {
                final totalLessons = lessonsByCourse[p.courseId] ?? 1;
                final pct = p.completionPercent(totalLessons);
                final courseTitle = titleByCourse[p.courseId] ?? '';
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => context.push('/analytics/${p.courseId}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.error.withValues(alpha: 0.12),
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    courseTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
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
              if (low.length > 4)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _expanded
                                ? 'Yashirish'
                                : 'va yana ${low.length - shown.length} o\'quvchi',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.error.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.error.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
