import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/courses/models/course_model.dart';
import '../../../features/progress/models/progress_model.dart';
import '../../../shared/services/course_service.dart';

class CourseProgressCard extends StatelessWidget {
  final CourseModel course;
  final String teacherId;

  const CourseProgressCard({
    super.key,
    required this.course,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return StreamBuilder<List<ProgressModel>>(
      stream: courseService.watchCourseProgress(course.id),
      builder: (context, snapshot) {
        final progresses = snapshot.data ?? [];
        final studentCount = progresses.length;
        final avgCompletion = studentCount == 0
            ? 0.0
            : progresses
                    .map((p) => p.completionPercent(course.totalLessons))
                    .fold(0.0, (a, b) => a + b) /
                studentCount;

        return _CardSurface(
          onTap: () => context.push('/courses/${course.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded,
                        color: AppColors.primary, size: 22),
                    onPressed: () => context.push('/analytics/${course.id}'),
                    tooltip: 'Analitika',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Chip(
                    icon: Icons.people_rounded,
                    label: '$studentCount talaba',
                    color: AppColors.info,
                    bg: AppColors.infoSoft,
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.play_lesson_rounded,
                    label: '${course.totalLessons} dars',
                    color: AppColors.accent,
                    bg: AppColors.accentSoft,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: avgCompletion / 100,
                        backgroundColor: AppColors.surfaceMuted,
                        color: avgCompletion >= 75
                            ? AppColors.secondary
                            : AppColors.primary,
                        minHeight: 7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${avgCompletion.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _CardSurface({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: child,
        ),
      ),
    );
  }
}
