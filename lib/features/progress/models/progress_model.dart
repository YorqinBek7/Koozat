import 'package:cloud_firestore/cloud_firestore.dart';

class LessonProgress {
  final String lessonId;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? score; // for quizzes (0-100)

  const LessonProgress({
    required this.lessonId,
    required this.isCompleted,
    this.completedAt,
    this.score,
  });

  factory LessonProgress.fromMap(Map<String, dynamic> map) {
    return LessonProgress(
      lessonId: map['lessonId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      score: map['score'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'score': score,
    };
  }
}

class ProgressModel {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final List<LessonProgress> lessonProgresses;
  final DateTime lastActiveAt;
  final DateTime enrolledAt;

  const ProgressModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.lessonProgresses,
    required this.lastActiveAt,
    required this.enrolledAt,
  });

  int get completedLessons =>
      lessonProgresses.where((lp) => lp.isCompleted).length;

  double completionPercent(int totalLessons) {
    if (totalLessons == 0) return 0;
    return (completedLessons / totalLessons) * 100;
  }

  double get averageScore {
    final scored = lessonProgresses
        .where((lp) => lp.score != null)
        .map((lp) => lp.score!)
        .toList();
    if (scored.isEmpty) return 0;
    return scored.reduce((a, b) => a + b) / scored.length;
  }

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> rawLessons = data['lessonProgresses'] ?? [];
    return ProgressModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      courseId: data['courseId'] ?? '',
      lessonProgresses: rawLessons
          .map((l) => LessonProgress.fromMap(l as Map<String, dynamic>))
          .toList(),
      lastActiveAt:
          (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      enrolledAt:
          (data['enrolledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'lessonProgresses': lessonProgresses.map((lp) => lp.toMap()).toList(),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'enrolledAt': Timestamp.fromDate(enrolledAt),
    };
  }

  ProgressModel copyWith({
    List<LessonProgress>? lessonProgresses,
    DateTime? lastActiveAt,
  }) {
    return ProgressModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      courseId: courseId,
      lessonProgresses: lessonProgresses ?? this.lessonProgresses,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      enrolledAt: enrolledAt,
    );
  }
}
