import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../features/submissions/models/submission_model.dart';

class SubmissionService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.submissionsCollection);

  // Bir o'quvchi + bir dars uchun bitta hujjat (qayta topshirsa yangilanadi).
  String _docId(String studentId, String lessonId) => '${studentId}_$lessonId';

  /// O'quvchi javobini topshiradi (status: pending).
  Future<void> submitAnswer({
    required String studentId,
    required String studentName,
    required String courseId,
    required String lessonId,
    required String lessonTitle,
    required String? progressId,
    required String answer,
  }) async {
    final model = SubmissionModel(
      id: _docId(studentId, lessonId),
      studentId: studentId,
      studentName: studentName,
      courseId: courseId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      progressId: progressId,
      answer: answer,
      status: SubmissionStatus.pending,
      submittedAt: DateTime.now(),
    );
    await _col.doc(model.id).set(model.toFirestore());
  }

  /// Bitta o'quvchining dars bo'yicha topshirig'ini kuzatadi.
  Stream<SubmissionModel?> watchForLesson(String studentId, String lessonId) {
    return _col
        .doc(_docId(studentId, lessonId))
        .snapshots()
        .map((d) => d.exists ? SubmissionModel.fromFirestore(d) : null);
  }

  /// Kursdagi barcha topshiriqlar (o'qituvchi uchun) — kutilayotgani yuqorida.
  Stream<List<SubmissionModel>> watchCourseSubmissions(String courseId) {
    return _col.where('courseId', isEqualTo: courseId).snapshots().map((s) {
      final list = s.docs.map(SubmissionModel.fromFirestore).toList();
      list.sort((a, b) {
        // Avval kutilayotganlar, keyin sana bo'yicha (yangi yuqorida).
        if (a.isPending != b.isPending) return a.isPending ? -1 : 1;
        return b.submittedAt.compareTo(a.submittedAt);
      });
      return list;
    });
  }

  /// O'qituvchining barcha kurslari bo'yicha kutilayotgan topshiriqlar soni.
  Stream<int> watchPendingCount(List<String> courseIds) {
    if (courseIds.isEmpty) return Stream.value(0);
    return _col
        .where('courseId', whereIn: courseIds)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// O'qituvchi topshiriqni baholaydi va dars progressini yangilaydi.
  Future<void> grade({
    required SubmissionModel submission,
    required int score,
    String? feedback,
  }) async {
    final batch = _db.batch();

    // 1. Topshiriqni baholangan deb belgilash.
    batch.update(_col.doc(submission.id), {
      'status': 'graded',
      'score': score,
      'feedback': feedback,
      'gradedAt': Timestamp.fromDate(DateTime.now()),
    });

    // 2. Dars progressini yangilash (bajarilgan + ball).
    final progressId = submission.progressId;
    if (progressId != null && progressId.isNotEmpty) {
      final progressRef = _db
          .collection(AppConstants.progressCollection)
          .doc(progressId);
      final snap = await progressRef.get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final List<dynamic> raw = List<dynamic>.from(
          data['lessonProgresses'] ?? const [],
        );
        final entry = {
          'lessonId': submission.lessonId,
          'isCompleted': true,
          'completedAt': Timestamp.fromDate(DateTime.now()),
          'score': score,
        };
        final idx = raw.indexWhere(
          (e) => (e as Map)['lessonId'] == submission.lessonId,
        );
        if (idx >= 0) {
          raw[idx] = entry;
        } else {
          raw.add(entry);
        }
        batch.update(progressRef, {
          'lessonProgresses': raw,
          'lastActiveAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    }

    await batch.commit();
  }
}
