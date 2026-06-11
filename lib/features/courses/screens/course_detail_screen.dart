import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/course_service.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../../progress/models/progress_model.dart';
import 'lesson_viewer_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

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
        final courseService = context.read<CourseService>();
        return StreamBuilder<List<LessonModel>>(
          stream: courseService.watchLessons(courseId),
          builder: (context, lessonsSnap) {
            final lessons = lessonsSnap.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Kurs tafsiloti'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => context.pop(),
                ),
                actions: user.isTeacher
                    ? [
                        IconButton(
                          icon: const Icon(Icons.assignment_turned_in_outlined),
                          onPressed: () =>
                              context.push('/submissions/$courseId'),
                          tooltip: 'Topshiriqlar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.bar_chart_rounded),
                          onPressed: () => context.push('/analytics/$courseId'),
                          tooltip: 'Analitika',
                        ),
                        const SizedBox(width: 4),
                      ]
                    : null,
              ),
              body: lessons.isEmpty
                  ? const _EmptyLessons()
                  : user.isTeacher
                  ? _TeacherLessonsView(lessons: lessons)
                  : _StudentLessonsView(
                      lessons: lessons,
                      courseId: courseId,
                      studentId: user.id,
                      studentName: user.name,
                    ),
              floatingActionButton: user.isTeacher
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppShadows.tinted(AppColors.primary),
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () => _showAddLessonSheet(
                          context,
                          courseService,
                          courseId,
                          lessons.length,
                        ),
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        icon: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Dars qo\'shish',
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
      },
    );
  }

  void _showAddLessonSheet(
    BuildContext context,
    CourseService courseService,
    String courseId,
    int currentCount,
  ) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final videoCtrl = TextEditingController();
    final List<_QuestionDraft> questions = [];
    LessonType selectedType = LessonType.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Yangi dars qo\'shish',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dars ma\'lumotlarini kiriting',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                const _SheetLabel('Dars nomi'),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Masalan: Kirish darsi',
                  ),
                ),
                const SizedBox(height: 14),
                _SheetLabel(
                  selectedType == LessonType.text
                      ? 'Dars matni / tavsif'
                      : 'Tavsif',
                ),
                TextField(
                  controller: contentCtrl,
                  maxLines: selectedType == LessonType.text ? 5 : 3,
                  decoration: const InputDecoration(hintText: 'Dars haqida...'),
                ),
                const SizedBox(height: 14),
                const _SheetLabel('Tur'),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'Matn',
                        icon: Icons.article_outlined,
                        isSelected: selectedType == LessonType.text,
                        onTap: () =>
                            setModalState(() => selectedType = LessonType.text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeChip(
                        label: 'Video',
                        icon: Icons.play_circle_outline,
                        isSelected: selectedType == LessonType.video,
                        onTap: () => setModalState(
                          () => selectedType = LessonType.video,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeChip(
                        label: 'Test',
                        icon: Icons.quiz_outlined,
                        isSelected: selectedType == LessonType.quiz,
                        onTap: () =>
                            setModalState(() => selectedType = LessonType.quiz),
                      ),
                    ),
                  ],
                ),

                // ─── Video havolasi (type == video) ───
                if (selectedType == LessonType.video) ...[
                  const SizedBox(height: 16),
                  const _SheetLabel('YouTube havolasi'),
                  TextField(
                    controller: videoCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://youtu.be/...',
                      prefixIcon: Icon(Icons.link_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'YouTube video havolasini joylashtiring',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],

                // ─── Test savollari (type == quiz) ───
                if (selectedType == LessonType.quiz) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SheetLabel('Test savollari'),
                      Text(
                        '${questions.length} ta savol',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  ...questions.asMap().entries.map((entry) {
                    final i = entry.key;
                    final q = entry.value;
                    return _QuestionEditor(
                      index: i + 1,
                      draft: q,
                      onRemove: () =>
                          setModalState(() => questions.removeAt(i)),
                      onCorrectChanged: (idx) =>
                          setModalState(() => q.correctIndex = idx),
                    );
                  }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setModalState(() => questions.add(_QuestionDraft())),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Savol qo\'shish'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppShadows.tinted(AppColors.primary),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) {
                        _toast(ctx, 'Dars nomini kiriting');
                        return;
                      }
                      if (selectedType == LessonType.video &&
                          videoCtrl.text.trim().isEmpty) {
                        _toast(ctx, 'YouTube havolasini kiriting');
                        return;
                      }
                      List<QuizQuestion> builtQuestions = const [];
                      if (selectedType == LessonType.quiz) {
                        builtQuestions = questions
                            .map((d) => d.build())
                            .whereType<QuizQuestion>()
                            .toList();
                        if (builtQuestions.isEmpty) {
                          _toast(
                            ctx,
                            'Kamida 1 ta to\'liq savol kiriting (savol + 2 variant)',
                          );
                          return;
                        }
                      }
                      await courseService.addLesson(
                        LessonModel(
                          id: const Uuid().v4(),
                          courseId: courseId,
                          title: titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                          type: selectedType,
                          orderIndex: currentCount,
                          createdAt: DateTime.now(),
                          videoUrl: selectedType == LessonType.video
                              ? videoCtrl.text.trim()
                              : null,
                          questions: builtQuestions,
                        ),
                      );
                      final courses = await courseService
                          .watchAllCourses()
                          .first;
                      final course = courses
                          .where((c) => c.id == courseId)
                          .firstOrNull;
                      if (course != null) {
                        await courseService.updateCourse(
                          CourseModel(
                            id: course.id,
                            title: course.title,
                            description: course.description,
                            teacherId: course.teacherId,
                            teacherName: course.teacherName,
                            totalLessons: currentCount + 1,
                            createdAt: course.createdAt,
                          ),
                        );
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Qo\'shish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Forma ichida bitta test savolini tahrirlash uchun vaqtinchalik holat.
class _QuestionDraft {
  final TextEditingController question = TextEditingController();
  final List<TextEditingController> options = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int correctIndex = 0;

  /// To'liq savolnigina qaytaradi (savol matni + kamida 2 ta variant).
  QuizQuestion? build() {
    final q = question.text.trim();
    final opts = options
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (q.isEmpty || opts.length < 2) return null;
    final correct = correctIndex < opts.length ? correctIndex : 0;
    return QuizQuestion(question: q, options: opts, correctIndex: correct);
  }
}

class _QuestionEditor extends StatelessWidget {
  final int index;
  final _QuestionDraft draft;
  final VoidCallback onRemove;
  final ValueChanged<int> onCorrectChanged;

  const _QuestionEditor({
    required this.index,
    required this.draft,
    required this.onRemove,
    required this.onCorrectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index-savol',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: draft.question,
            decoration: const InputDecoration(hintText: 'Savol matni'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Variantlar (to\'g\'risini belgilang)',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          ...List.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Radio<int>(
                    value: i,
                    groupValue: draft.correctIndex,
                    onChanged: (v) => onCorrectChanged(v ?? 0),
                    visualDensity: VisualDensity.compact,
                    activeColor: AppColors.secondary,
                  ),
                  Expanded(
                    child: TextField(
                      controller: draft.options[i],
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '${i + 1}-variant',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLessons extends StatelessWidget {
  const _EmptyLessons();

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
                Icons.play_lesson_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hali dars qo\'shilmagan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Birinchi darsni qo\'shish uchun pastdagi tugmani bosing',
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

class _TeacherLessonsView extends StatelessWidget {
  final List<LessonModel> lessons;
  const _TeacherLessonsView({required this.lessons});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _LessonTile(
        lesson: lessons[i],
        index: i + 1,
        isCompleted: false,
        showCheck: false,
        onTap: () => context.push(
          '/lesson',
          extra: LessonViewerArgs(lesson: lessons[i], isTeacher: true),
        ),
      ),
    );
  }
}

class _StudentLessonsView extends StatefulWidget {
  final List<LessonModel> lessons;
  final String courseId;
  final String studentId;
  final String studentName;
  const _StudentLessonsView({
    required this.lessons,
    required this.courseId,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<_StudentLessonsView> createState() => _StudentLessonsViewState();
}

class _StudentLessonsViewState extends State<_StudentLessonsView> {
  late Future<ProgressModel?> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = context.read<CourseService>().getProgress(
      widget.studentId,
      widget.courseId,
    );
  }

  void _refresh() {
    setState(() {
      _progressFuture = context.read<CourseService>().getProgress(
        widget.studentId,
        widget.courseId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProgressModel?>(
      future: _progressFuture,
      builder: (context, snap) {
        final progress = snap.data;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: widget.lessons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final lesson = widget.lessons[i];
            final isCompleted =
                progress?.lessonProgresses.any(
                  (lp) => lp.lessonId == lesson.id && lp.isCompleted,
                ) ??
                false;
            return _LessonTile(
              lesson: lesson,
              index: i + 1,
              isCompleted: isCompleted,
              showCheck: true,
              onTap: () async {
                final result = await context.push<bool>(
                  '/lesson',
                  extra: LessonViewerArgs(
                    lesson: lesson,
                    isTeacher: false,
                    progressId: progress?.id,
                    isCompleted: isCompleted,
                    studentId: widget.studentId,
                    studentName: widget.studentName,
                  ),
                );
                if (result == true) _refresh();
              },
            );
          },
        );
      },
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final bool isCompleted;
  final bool showCheck;
  final VoidCallback? onTap;

  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    required this.showCheck,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeIcon = switch (lesson.type) {
      LessonType.video => Icons.play_circle_outline,
      LessonType.quiz => Icons.quiz_outlined,
      LessonType.text => Icons.article_outlined,
    };
    final typeLabel = switch (lesson.type) {
      LessonType.video => 'Video',
      LessonType.quiz => 'Test · ${lesson.questions.length} savol',
      LessonType.text => 'Matn',
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.secondarySoft.withValues(alpha: 0.4)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isCompleted
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isCompleted ? AppGradients.success : null,
                  color: isCompleted ? null : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '$index',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(typeIcon, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${lesson.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
