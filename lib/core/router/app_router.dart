import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/teacher_dashboard_screen.dart';
import '../../features/dashboard/screens/student_dashboard_screen.dart';
import '../../features/courses/screens/course_list_screen.dart';
import '../../features/courses/screens/course_detail_screen.dart';
import '../../features/courses/screens/create_course_screen.dart';
import '../../features/courses/screens/lesson_viewer_screen.dart';
import '../../features/progress/screens/analytics_screen.dart';
import '../../features/submissions/screens/submissions_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              switch (authState.status) {
                case AuthStatus.unknown:
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                case AuthStatus.unauthenticated:
                  return const LoginScreen();
                case AuthStatus.authenticated:
                  final user = authState.user!;
                  return user.isTeacher
                      ? const TeacherDashboardScreen()
                      : const StudentDashboardScreen();
              }
            },
          );
        },
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (_, __) => const CourseListScreen(),
      ),
      GoRoute(
        path: '/courses/create',
        name: 'create-course',
        builder: (_, __) => const CreateCourseScreen(),
      ),
      GoRoute(
        path: '/courses/:courseId',
        name: 'course-detail',
        builder: (_, state) =>
            CourseDetailScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/analytics/:courseId',
        name: 'analytics',
        builder: (_, state) =>
            AnalyticsScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/lesson',
        name: 'lesson',
        builder: (_, state) =>
            LessonViewerScreen(args: state.extra as LessonViewerArgs),
      ),
      GoRoute(
        path: '/submissions/:courseId',
        name: 'submissions',
        builder: (_, state) =>
            SubmissionsScreen(courseId: state.pathParameters['courseId']!),
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
