import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/course_service.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../models/course_model.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await context.read<CourseService>().createCourse(
            CourseModel(
              id: '',
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              teacherId: user.id,
              teacherName: user.name,
              totalLessons: 0,
              createdAt: DateTime.now(),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kurs muvaffaqiyatli yaratildi!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangi kurs'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.tinted(AppColors.primary),
                ),
                child: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Yangi kurs yarating',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Talabalaringiz uchun kurs ma\'lumotlarini kiriting',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              const _FieldLabel('Kurs nomi'),
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Masalan: Algoritmlar asoslari',
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Kurs nomini kiriting';
                  }
                  if (v.trim().length < 3) return 'Nom juda qisqa';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Tavsif'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Kurs haqida qisqa ma\'lumot...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Tavsif kiriting';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: _isLoading
                      ? null
                      : AppShadows.tinted(AppColors.primary),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _create,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.check_rounded, size: 18),
                  label: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kurs yaratish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

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
