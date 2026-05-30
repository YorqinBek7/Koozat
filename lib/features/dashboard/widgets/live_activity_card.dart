import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/courses/models/course_model.dart';
import '../../../features/progress/models/progress_model.dart';
import '../../../shared/services/course_service.dart';

class LiveActivityCard extends StatelessWidget {
  final List<CourseModel> courses;
  const LiveActivityCard({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    final courseService = context.read<CourseService>();
    final courseIds = courses.map((c) => c.id).toList();
    final courseTitleById = {for (final c in courses) c.id: c.title};

    return StreamBuilder<List<ProgressModel>>(
      stream: courseService.watchProgressForCourses(courseIds),
      builder: (context, snap) {
        final all = snap.data ?? [];
        final now = DateTime.now();
        final onlineCount = all
            .where((p) => now.difference(p.lastActiveAt).inMinutes < 5)
            .length;
        final recent = all.take(4).toList();

        return Container(
          padding: const EdgeInsets.all(18),
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
                  const _PulsingDot(),
                  const SizedBox(width: 10),
                  const Text(
                    'Live faollik',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      onlineCount > 0
                          ? '$onlineCount online'
                          : 'Hech kim online emas',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (recent.isEmpty)
                _Empty()
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                      sizeFactor: anim,
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(recent.map((p) => p.id).join('-')),
                    children: [
                      for (var i = 0; i < recent.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: i == recent.length - 1 ? 0 : 12),
                          child: _ActivityRow(
                            progress: recent[i],
                            courseTitle:
                                courseTitleById[recent[i].courseId] ?? '',
                            isOnline: now
                                    .difference(recent[i].lastActiveAt)
                                    .inMinutes <
                                5,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ProgressModel progress;
  final String courseTitle;
  final bool isOnline;
  const _ActivityRow({
    required this.progress,
    required this.courseTitle,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final initial = progress.studentName.isEmpty
        ? '?'
        : progress.studentName.trim()[0].toUpperCase();
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: progress.studentName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: courseTitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const TextSpan(text: ' kursida faol edi'),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimeAgo(progress.lastActiveAt),
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
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return '${(diff.inDays / 7).floor()} hafta oldin';
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.podcasts_rounded,
                size: 32, color: AppColors.textMuted),
            const SizedBox(height: 8),
            const Text(
              'Hozircha faollik yo\'q',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: 12 * (0.6 + t * 0.8),
                  height: 12 * (0.6 + t * 0.8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
