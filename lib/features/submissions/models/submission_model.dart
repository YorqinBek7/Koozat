import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { pending, graded }

/// O'quvchining bir dars bo'yicha topshirig'i (matn javob).
/// O'qituvchi baholagach `status` graded bo'ladi va ball qo'yiladi.
class SubmissionModel {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String lessonId;
  final String lessonTitle;
  final String? progressId;
  final String answer;
  final SubmissionStatus status;
  final int? score; // 0-100, baholangach
  final String? feedback; // o'qituvchi izohi
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const SubmissionModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.lessonId,
    required this.lessonTitle,
    required this.progressId,
    required this.answer,
    required this.status,
    this.score,
    this.feedback,
    required this.submittedAt,
    this.gradedAt,
  });

  bool get isGraded => status == SubmissionStatus.graded;
  bool get isPending => status == SubmissionStatus.pending;

  factory SubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubmissionModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      courseId: data['courseId'] ?? '',
      lessonId: data['lessonId'] ?? '',
      lessonTitle: data['lessonTitle'] ?? '',
      progressId: data['progressId'],
      answer: data['answer'] ?? '',
      status: data['status'] == 'graded'
          ? SubmissionStatus.graded
          : SubmissionStatus.pending,
      score: data['score'],
      feedback: data['feedback'],
      submittedAt:
          (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gradedAt: (data['gradedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'progressId': progressId,
      'answer': answer,
      'status': status == SubmissionStatus.graded ? 'graded' : 'pending',
      'score': score,
      'feedback': feedback,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
    };
  }
}
