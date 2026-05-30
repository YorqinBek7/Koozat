import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/course_service.dart';
import '../models/lesson_model.dart';

class LessonViewerArgs {
  final LessonModel lesson;
  final bool isTeacher;
  final String? progressId;
  final bool isCompleted;

  const LessonViewerArgs({
    required this.lesson,
    required this.isTeacher,
    this.progressId,
    this.isCompleted = false,
  });
}

class LessonViewerScreen extends StatelessWidget {
  final LessonViewerArgs args;
  const LessonViewerScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final lesson = args.lesson;
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (lesson.type) {
        LessonType.video => _VideoLesson(args: args),
        LessonType.quiz => _QuizLesson(args: args),
        LessonType.text => _TextLesson(args: args),
      },
    );
  }
}

// ─── Mark-complete tugmasi (talaba uchun) ──────────────────────────────────

class _CompleteButton extends StatefulWidget {
  final LessonViewerArgs args;
  final int? score;
  final String label;

  const _CompleteButton({
    required this.args,
    this.score,
    this.label = 'Darsni yakunladim',
  });

  @override
  State<_CompleteButton> createState() => _CompleteButtonState();
}

class _CompleteButtonState extends State<_CompleteButton> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.args.isTeacher) return const SizedBox.shrink();
    if (widget.args.progressId == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Bu darsni yakunlash uchun avval kursga yozilishingiz kerak.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : _complete,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(widget.label),
        ),
      ),
    );
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    await context.read<CourseService>().completeLesson(
          progressId: widget.args.progressId!,
          lessonId: widget.args.lesson.id,
          score: widget.score,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dars bajarildi! 🎉',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop(true);
  }
}

// ─── Video darsi ───────────────────────────────────────────────────────────

class _VideoLesson extends StatefulWidget {
  final LessonViewerArgs args;
  const _VideoLesson({required this.args});

  @override
  State<_VideoLesson> createState() => _VideoLessonState();
}

class _VideoLessonState extends State<_VideoLesson> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    final url = widget.args.lesson.videoUrl ?? '';
    _videoId = YoutubePlayerController.convertUrlToId(url);
    if (_videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.args.lesson;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_controller != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: YoutubePlayer(controller: _controller!),
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Center(
                    child: Text(
                      'Video havolasi noto\'g\'ri yoki topilmadi',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              if (lesson.content.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  lesson.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.args.isCompleted)
          const _CompletedBanner()
        else
          _CompleteButton(args: widget.args),
      ],
    );
  }
}

// ─── Matn darsi ──────────────────────────────────────────────────────────────

class _TextLesson extends StatelessWidget {
  final LessonViewerArgs args;
  const _TextLesson({required this.args});

  @override
  Widget build(BuildContext context) {
    final lesson = args.lesson;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                lesson.content.trim().isEmpty
                    ? 'Bu dars uchun matn kiritilmagan.'
                    : lesson.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (args.isCompleted)
          const _CompletedBanner()
        else
          _CompleteButton(args: args),
      ],
    );
  }
}

// ─── Test darsi ──────────────────────────────────────────────────────────────

class _QuizLesson extends StatefulWidget {
  final LessonViewerArgs args;
  const _QuizLesson({required this.args});

  @override
  State<_QuizLesson> createState() => _QuizLessonState();
}

class _QuizLessonState extends State<_QuizLesson> {
  late final List<int?> _answers;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.args.lesson.questions.length, null);
  }

  int get _correctCount {
    final qs = widget.args.lesson.questions;
    var c = 0;
    for (var i = 0; i < qs.length; i++) {
      if (_answers[i] == qs[i].correctIndex) c++;
    }
    return c;
  }

  int get _scorePercent {
    final total = widget.args.lesson.questions.length;
    if (total == 0) return 0;
    return ((_correctCount / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final qs = widget.args.lesson.questions;
    final isTeacher = widget.args.isTeacher;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_submitted) _ScoreCard(percent: _scorePercent,
                  correct: _correctCount, total: qs.length),
              ...qs.asMap().entries.map((e) {
                final i = e.key;
                final q = e.value;
                return _QuestionCard(
                  index: i + 1,
                  question: q,
                  selected: _answers[i],
                  // O'qituvchiga to'g'ri javob doim ko'rinadi; talabaga — yuborgandan keyin
                  revealCorrect: isTeacher || _submitted,
                  enabled: !isTeacher && !_submitted,
                  onSelect: (idx) => setState(() => _answers[i] = idx),
                );
              }),
            ],
          ),
        ),
        if (isTeacher)
          const _CompletedBanner(label: 'Test ko\'rinishi (o\'qituvchi)')
        else if (widget.args.isCompleted)
          const _CompletedBanner()
        else if (!_submitted)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _answers.contains(null)
                    ? null
                    : () => setState(() => _submitted = true),
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                label: Text(_answers.contains(null)
                    ? 'Barcha savollarga javob bering'
                    : 'Testni yakunlash'),
              ),
            ),
          )
        else
          _CompleteButton(
            args: widget.args,
            score: _scorePercent,
            label: 'Natijani saqlash ($_scorePercent%)',
          ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final QuizQuestion question;
  final int? selected;
  final bool revealCorrect;
  final bool enabled;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.revealCorrect,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${question.question}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...question.options.asMap().entries.map((e) {
            final i = e.key;
            final opt = e.value;
            final isCorrect = i == question.correctIndex;
            final isSelected = i == selected;

            Color bg = AppColors.background;
            Color borderColor = AppColors.border;
            IconData? trailing;
            Color? trailingColor;

            if (revealCorrect && isCorrect) {
              bg = AppColors.secondarySoft.withValues(alpha: 0.4);
              borderColor = AppColors.secondary;
              trailing = Icons.check_circle_rounded;
              trailingColor = AppColors.secondary;
            } else if (revealCorrect && isSelected && !isCorrect) {
              bg = AppColors.error.withValues(alpha: 0.08);
              borderColor = AppColors.error;
              trailing = Icons.cancel_rounded;
              trailingColor = AppColors.error;
            } else if (isSelected) {
              bg = AppColors.primarySoft;
              borderColor = AppColors.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: enabled ? () => onSelect(i) : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (trailing != null)
                        Icon(trailing, size: 18, color: trailingColor),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int percent;
  final int correct;
  final int total;
  const _ScoreCard({
    required this.percent,
    required this.correct,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final passed = percent >= 60;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: passed ? AppGradients.success : null,
        color: passed ? null : AppColors.error,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Natija: $percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$total ta savoldan $correct ta to\'g\'ri',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final String label;
  const _CompletedBanner({this.label = 'Bu dars bajarilgan'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
