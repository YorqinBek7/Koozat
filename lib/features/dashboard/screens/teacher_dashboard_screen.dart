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
import '../widgets/stat_card.dart';
import '../widgets/course_progress_card.dart';
import '../widgets/live_activity_card.dart';
import '../widgets/low_performers_card.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
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
                _HomeTab(user: user),
                _CoursesTab(teacherId: user.id),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _selectedIndex,
            onChanged: (i) => setState(() => _selectedIndex = i),
          ),
          floatingActionButton: _selectedIndex == 1
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppShadows.tinted(AppColors.primary),
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () => context.push('/courses/create'),
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'Kurs qo\'shish',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  final UserModel user;
  const _HomeTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return StreamBuilder<List<CourseModel>>(
      stream: courseService.watchTeacherCourses(user.id),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _HeaderGreeting(user: user, subtitle: 'O\'qituvchi paneli'),
            const SizedBox(height: 20),
            _StatsRow(courses: courses),
            const SizedBox(height: 20),
            LowPerformersCard(courses: courses),
            LiveActivityCard(courses: courses),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
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
                TextButton(
                  onPressed: () => context.push('/courses'),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    children: [
                      Text('Hammasi'),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (courses.isEmpty)
              const _EmptyCoursesPlaceholder()
            else
              ...courses.take(3).map(
                    (course) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CourseProgressCard(
                        course: course,
                        teacherId: user.id,
                      ),
                    ),
                  ),
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
        _IconButton(
          icon: Icons.logout_rounded,
          onTap: () =>
              context.read<AuthBloc>().add(const AuthSignOutRequested()),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<CourseModel> courses;
  const _StatsRow({required this.courses});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Kurslar',
            value: '${courses.length}',
            icon: Icons.menu_book_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Faol',
            value: '${courses.where((c) => c.isActive).length}',
            icon: Icons.bolt_rounded,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Darslar',
            value: '${courses.fold(0, (sum, c) => sum + c.totalLessons)}',
            icon: Icons.play_lesson_rounded,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _CoursesTab extends StatelessWidget {
  final String teacherId;
  const _CoursesTab({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final courseService = context.read<CourseService>();
    return StreamBuilder<List<CourseModel>>(
      stream: courseService.watchTeacherCourses(teacherId),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Mening kurslarim',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? const _EmptyCoursesPlaceholder()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => CourseProgressCard(
                        course: courses[i],
                        teacherId: teacherId,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
class _EmptyCoursesPlaceholder extends StatelessWidget {
  const _EmptyCoursesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hali kurs yo\'q',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Yangi kurs qo\'shish uchun + tugmasini bosing',
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
              icon: Icon(Icons.dashboard_rounded),
              label: 'Asosiy',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Kurslar',
            ),
          ],
        ),
      ),
    );
  }
}
