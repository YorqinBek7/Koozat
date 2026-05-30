import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/course_service.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/courses/models/course_model.dart';
import '../../../features/progress/models/progress_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _MyProgressTab(user: user),
                _AllCoursesTab(studentId: user.id, studentName: user.name),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _selectedIndex,
            onChanged: (i) => setState(() => _selectedIndex = i),
          ),
        );
      },
    );
  }
}

class _MyProgressTab extends StatelessWidget {
  final UserModel user;
  const _MyProgressTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return StreamBuilder<List<ProgressModel>>(
      stream: courseService.watchStudentProgress(user.id),
      builder: (context, progressSnap) {
        final progresses = progressSnap.data ?? [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _HeaderGreeting(user: user, subtitle: 'Talaba paneli'),
            const SizedBox(height: 20),
            if (progresses.isEmpty)
              const _EmptyEnrollment()
            else ...[
              _OverallStats(progresses: progresses),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Kurslarim',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              ...progresses.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentCourseCard(progress: p),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HeaderGreeting extends StatelessWidget {
  final UserModel user;
  final String subtitle;
  const _HeaderGreeting({required this.user, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final firstName = user.name.split(' ').first;
    final initial = firstName.isEmpty ? '?' : firstName[0].toUpperCase();
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.tinted(AppColors.primary),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salom, $firstName 👋',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverallStats extends StatelessWidget {
  final List<ProgressModel> progresses;
  const _OverallStats({required this.progresses});

  @override
  Widget build(BuildContext context) {
    final totalCompleted =
        progresses.fold(0, (sum, p) => sum + p.completedLessons);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.tinted(AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Umumiy progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalCompleted',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'dars bajarildi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatPill(
                label: '${progresses.length} kurs',
                icon: Icons.menu_book_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCourseCard extends StatelessWidget {
  final ProgressModel progress;
  const _StudentCourseCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return FutureBuilder<List<CourseModel>>(
      future: courseService.watchAllCourses().first,
      builder: (context, snap) {
        final course = snap.data?.firstWhere(
          (c) => c.id == progress.courseId,
          orElse: () => CourseModel(
            id: progress.courseId,
            title: 'Kurs yuklanmoqda...',
            description: '',
            teacherId: '',
            teacherName: '',
            totalLessons: 1,
            createdAt: DateTime.now(),
          ),
        );

        final total = course?.totalLessons ?? 1;
        final percent = progress.completionPercent(total);
        final isComplete = percent >= 100;

        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () => context.push('/courses/${progress.courseId}'),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isComplete
                              ? AppColors.secondarySoft
                              : AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          isComplete
                              ? Icons.workspace_premium_rounded
                              : Icons.menu_book_rounded,
                          color: isComplete
                              ? AppColors.secondary
                              : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course?.title ?? '',
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
                              '${progress.completedLessons} / $total dars',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tugatildi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
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
                            value: percent / 100,
                            backgroundColor: AppColors.surfaceMuted,
                            color: isComplete
                                ? AppColors.secondary
                                : AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
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
            ),
          ),
        );
      },
    );
  }
}

class _EmptyEnrollment extends StatelessWidget {
  const _EmptyEnrollment();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Hali kursga yozilmadingiz',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pastdagi "Kurslar" bo\'limidan o\'zingizga kerakli kursga yoziling',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AllCoursesTab extends StatelessWidget {
  final String studentId;
  final String studentName;
  const _AllCoursesTab({
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            'Mavjud kurslar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'O\'zingizga mos kursni tanlang va yoziling',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CourseModel>>(
            stream: courseService.watchAllCourses(),
            builder: (context, snap) {
              final courses = snap.data ?? [];
              if (courses.isEmpty) {
                return const Center(
                  child: Text(
                    'Hali kurs mavjud emas',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _EnrollableCourseCard(
                  course: courses[i],
                  studentId: studentId,
                  studentName: studentName,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnrollableCourseCard extends StatelessWidget {
  final CourseModel course;
  final String studentId;
  final String studentName;

  const _EnrollableCourseCard({
    required this.course,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return FutureBuilder<ProgressModel?>(
      future: courseService.getProgress(studentId, course.id),
      builder: (context, snap) {
        final isEnrolled = snap.data != null;

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
                          'O\'qituvchi: ${course.teacherName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_lesson_rounded,
                            size: 13, color: AppColors.accent),
                        const SizedBox(width: 5),
                        Text(
                          '${course.totalLessons} dars',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isEnrolled)
                OutlinedButton.icon(
                  onPressed: () => context.push('/courses/${course.id}'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Davom etish'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    await courseService.enrollStudent(
                      studentId: studentId,
                      studentName: studentName,
                      courseId: course.id,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${course.title} kursiga yozildingiz!',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Kursga yozilish'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.currentIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onChanged,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              label: 'Progressim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Kurslar',
            ),
          ],
        ),
      ),
    );
  }
}
