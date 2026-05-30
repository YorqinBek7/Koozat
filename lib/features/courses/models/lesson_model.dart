import 'package:cloud_firestore/cloud_firestore.dart';

enum LessonType { video, text, quiz }

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? const []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final LessonType type;
  final int orderIndex;
  final int durationMinutes;
  final DateTime createdAt;
  final String? videoUrl;
  final List<QuizQuestion> questions;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.type,
    required this.orderIndex,
    this.durationMinutes = 10,
    required this.createdAt,
    this.videoUrl,
    this.questions = const [],
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: _typeFromString(data['type']),
      orderIndex: data['orderIndex'] ?? 0,
      durationMinutes: data['durationMinutes'] ?? 10,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      videoUrl: data['videoUrl'],
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q)))
              .toList() ??
          const [],
    );
  }

  static LessonType _typeFromString(String? type) {
    switch (type) {
      case 'video':
        return LessonType.video;
      case 'quiz':
        return LessonType.quiz;
      default:
        return LessonType.text;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'title': title,
      'content': content,
      'type': type.name,
      'orderIndex': orderIndex,
      'durationMinutes': durationMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
      'videoUrl': videoUrl,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}
