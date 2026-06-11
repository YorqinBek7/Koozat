import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/course_service.dart';
import 'shared/services/demo_seeder.dart';
import 'shared/services/submission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KoozatApp());
}

class KoozatApp extends StatefulWidget {
  const KoozatApp({super.key});

  @override
  State<KoozatApp> createState() => _KoozatAppState();
}

class _KoozatAppState extends State<KoozatApp> {
  late final AuthService _authService;
  late final CourseService _courseService;
  late final DemoSeeder _demoSeeder;
  late final SubmissionService _submissionService;
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _courseService = CourseService();
    _demoSeeder = DemoSeeder();
    _submissionService = SubmissionService();
    _authBloc = AuthBloc(_authService)..add(const AuthSubscriptionRequested());
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>.value(value: _authService),
        RepositoryProvider<CourseService>.value(value: _courseService),
        RepositoryProvider<DemoSeeder>.value(value: _demoSeeder),
        RepositoryProvider<SubmissionService>.value(value: _submissionService),
      ],
      child: BlocProvider<AuthBloc>.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'Koozat',
          theme: AppTheme.light,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
