import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../features/courses/models/course_model.dart';
import '../../features/courses/models/lesson_model.dart';
import '../../features/progress/models/progress_model.dart';

class CourseService {
  final _db = FirebaseFirestore.instance;

  // ─── Courses ───────────────────────────────────────────────────────────────

  Stream<List<CourseModel>> watchTeacherCourses(String teacherId) {
    return _db
        .collection(AppConstants.coursesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(CourseModel.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<CourseModel>> watchAllCourses() {
    return _db
        .collection(AppConstants.coursesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) {
          final list = s.docs.map(CourseModel.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<CourseModel> createCourse(CourseModel course) async {
    final doc = await _db
        .collection(AppConstants.coursesCollection)
        .add(course.toFirestore());
    final snap = await doc.get();
    return CourseModel.fromFirestore(snap);
  }

  Future<void> updateCourse(CourseModel course) async {
    await _db
        .collection(AppConstants.coursesCollection)
        .doc(course.id)
        .update(course.toFirestore());
  }

  Future<void> deleteCourse(String courseId) async {
    await _db
        .collection(AppConstants.coursesCollection)
        .doc(courseId)
        .delete();
  }

  // ─── Lessons ───────────────────────────────────────────────────────────────

  Stream<List<LessonModel>> watchLessons(String courseId) {
    return _db
        .collection(AppConstants.lessonsCollection)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((s) {
          final list = s.docs.map(LessonModel.fromFirestore).toList();
          list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          return list;
        });
  }

  Future<void> addLesson(LessonModel lesson) async {
    await _db
        .collection(AppConstants.lessonsCollection)
        .add(lesson.toFirestore());
  }

  Future<void> deleteLesson(String lessonId) async {
    await _db
        .collection(AppConstants.lessonsCollection)
        .doc(lessonId)
        .delete();
  }

  // ─── Progress ──────────────────────────────────────────────────────────────

  Stream<List<ProgressModel>> watchCourseProgress(String courseId) {
    return _db
        .collection(AppConstants.progressCollection)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((s) => s.docs.map(ProgressModel.fromFirestore).toList());
  }

  Stream<List<ProgressModel>> watchProgressForCourses(List<String> courseIds) {
    if (courseIds.isEmpty) return Stream.value(const []);
    return _db
        .collection(AppConstants.progressCollection)
        .where('courseId', whereIn: courseIds)
        .snapshots()
        .map((s) {
      final list = s.docs.map(ProgressModel.fromFirestore).toList();
      list.sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
      return list;
    });
  }

  Stream<List<ProgressModel>> watchStudentProgress(String studentId) {
    return _db
        .collection(AppConstants.progressCollection)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) => s.docs.map(ProgressModel.fromFirestore).toList());
  }

  Future<ProgressModel?> getProgress(String studentId, String courseId) async {
    final snap = await _db
        .collection(AppConstants.progressCollection)
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ProgressModel.fromFirestore(snap.docs.first);
  }

  Future<ProgressModel> enrollStudent({
    required String studentId,
    required String studentName,
    required String courseId,
  }) async {
    final progress = ProgressModel(
      id: '',
      studentId: studentId,
      studentName: studentName,
      courseId: courseId,
      lessonProgresses: [],
      lastActiveAt: DateTime.now(),
      enrolledAt: DateTime.now(),
    );
    final doc = await _db
        .collection(AppConstants.progressCollection)
        .add(progress.toFirestore());
    final snap = await doc.get();
    return ProgressModel.fromFirestore(snap);
  }

  Future<void> completeLesson({
    required String progressId,
    required String lessonId,
    int? score,
  }) async {
    final docRef = _db.collection(AppConstants.progressCollection).doc(progressId);
    final snap = await docRef.get();
    final progress = ProgressModel.fromFirestore(snap);

    final updated = List<LessonProgress>.from(progress.lessonProgresses);
    final existingIndex = updated.indexWhere((lp) => lp.lessonId == lessonId);
    final newEntry = LessonProgress(
      lessonId: lessonId,
      isCompleted: true,
      completedAt: DateTime.now(),
      score: score,
    );
    if (existingIndex >= 0) {
      updated[existingIndex] = newEntry;
    } else {
      updated.add(newEntry);
    }

    await docRef.update({
      'lessonProgresses': updated.map((lp) => lp.toMap()).toList(),
      'lastActiveAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
