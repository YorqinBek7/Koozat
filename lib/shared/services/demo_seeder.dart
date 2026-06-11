import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Firestore'ga realistik demo ma'lumot (darslar + o'quvchi progressi) yozadi.
///
/// Darslar kurs mavzusiga qarab tanlanadi (dasturlash, ingliz tili,
/// matematika yoki umumiy) — haqiqiy nomlar, mazmun va viktorina savollari.
/// Yaratilgan hujjatlarda `isDemo: true` belgisi bo'ladi.
class DemoSeeder {
  final _db = FirebaseFirestore.instance;

  static const _names = [
    'Ali Karimov',
    'Dilnoza Rahimova',
    'Sardor Toshmatov',
    'Madina Yusupova',
    'Jasur Aliyev',
    'Nigora Sodiqova',
    'Bekzod Umarov',
    'Sevara Qodirova',
    'Otabek Nazarov',
    'Gulnoza Ismoilova',
    'Shoxrux Mahmudov',
    'Kamola Rustamova',
    'Aziz Tursunov',
    'Malika Hamidova',
    'Javohir Saidov',
    'Zarina Olimova',
    'Ulug\'bek Ergashev',
    'Feruza Nabiyeva',
    'Diyor Komilov',
    'Oygul Sattorova',
  ];

  // ─── Dasturlash (Python) paketi ────────────────────────────────────────────
  static const _programmingPack = [
    {
      'title': 'Dasturlashga kirish',
      'type': 'video',
      'duration': 10,
      'content':
          'Dasturlash nima, qayerda ishlatiladi va Python tili bilan '
              'tanishamiz. Birinchi dastur: print("Salom, dunyo!").',
    },
    {
      'title': 'O\'zgaruvchilar va ma\'lumot turlari',
      'type': 'text',
      'duration': 14,
      'content':
          'O\'zgaruvchi qiymat saqlaydi. Masalan: ism = "Ali", yosh = 18, '
              'narx = 4.5. Asosiy turlar: int, float, str, bool.',
    },
    {
      'title': 'Shartli operatorlar (if/else)',
      'type': 'text',
      'duration': 15,
      'content':
          'if yosh >= 18: print("Voyaga yetgan") else: print("Yosh"). '
              'Shartlar dasturni qaror qabul qilishga o\'rgatadi.',
    },
    {
      'title': 'Tsikllar (for va while)',
      'type': 'text',
      'duration': 16,
      'content':
          'for i in range(5): print(i) — 0 dan 4 gacha chiqaradi. '
              'Tsikllar amallarni takrorlash uchun ishlatiladi.',
    },
    {
      'title': 'Funksiyalar',
      'type': 'video',
      'duration': 12,
      'content':
          'def yigindi(a, b): return a + b. Funksiya kodni qayta '
              'ishlatish va tartibga solish imkonini beradi.',
    },
    {
      'title': 'Ro\'yxat va lug\'atlar',
      'type': 'text',
      'duration': 14,
      'content':
          'Ro\'yxat: mevalar = ["olma", "banan"]. Lug\'at: '
              'talaba = {"ism": "Ali", "yosh": 18}.',
    },
    {
      'title': 'Oraliq nazorat testi',
      'type': 'quiz',
      'duration': 10,
      'content': 'Python asoslari bo\'yicha bilimingizni tekshiring.',
      'questions': [
        {
          'question': 'Python\'da o\'zgaruvchi qanday e\'lon qilinadi?',
          'options': ['var x = 5', 'x = 5', 'int x = 5', 'let x = 5'],
          'correctIndex': 1,
        },
        {
          'question': 'Ro\'yxat (list) qaysi qavs bilan yoziladi?',
          'options': ['( )', '{ }', '[ ]', '< >'],
          'correctIndex': 2,
        },
        {
          'question': 'Ekranga matn chiqarish funksiyasi qaysi?',
          'options': ['echo()', 'print()', 'console.log()', 'write()'],
          'correctIndex': 1,
        },
      ],
    },
    {
      'title': 'Amaliy loyiha: kalkulyator',
      'type': 'text',
      'duration': 20,
      'content':
          'Oddiy kalkulyator yozamiz: ikki sonni qo\'shish, ayirish, '
              'ko\'paytirish va bo\'lish funksiyalari bilan.',
    },
    {
      'title': 'Yakuniy imtihon',
      'type': 'quiz',
      'duration': 15,
      'content': 'Butun kurs bo\'yicha yakuniy test.',
      'questions': [
        {
          'question': 'for tsikli nima uchun ishlatiladi?',
          'options': ['Takrorlash', 'Shart tekshirish', 'Funksiya', 'Import'],
          'correctIndex': 0,
        },
        {
          'question': 'def kalit so\'zi nimani bildiradi?',
          'options': ['O\'zgaruvchi', 'Tsikl', 'Funksiya', 'Ro\'yxat'],
          'correctIndex': 2,
        },
        {
          'question': 'Lug\'at (dict) qanday yoziladi?',
          'options': ['[ ]', '{ }', '( )', '" "'],
          'correctIndex': 1,
        },
      ],
    },
  ];

  // ─── Ingliz tili paketi ─────────────────────────────────────────────────────
  static const _englishPack = [
    {
      'title': 'Inglizcha alifbo va talaffuz',
      'type': 'video',
      'duration': 10,
      'content':
          '26 ta harf: A, B, C ... Z. To\'g\'ri talaffuz tilni '
              'o\'rganishning birinchi qadami.',
    },
    {
      'title': 'Salomlashish (Greetings)',
      'type': 'text',
      'duration': 12,
      'content':
          'Hello! Hi! Good morning! How are you? — I am fine, thank you. '
              'Kundalik muloqotning asosiy iboralari.',
    },
    {
      'title': 'Shaxs olmoshlari (Pronouns)',
      'type': 'text',
      'duration': 12,
      'content': 'I, you, he, she, it, we, they. Gapning egasi sifatida ishlaydi.',
    },
    {
      'title': 'To be fe\'li (am / is / are)',
      'type': 'text',
      'duration': 14,
      'content':
          'I am, You are, He/She/It is, We/They are. '
              'Masalan: I am a student. She is a teacher.',
    },
    {
      'title': 'Present Simple zamoni',
      'type': 'video',
      'duration': 15,
      'content':
          'Har kungi takroriy ish-harakatlar: I work, She works. '
              'He/She/It bilan fe\'lga -s qo\'shiladi.',
    },
    {
      'title': 'Kundalik so\'zlar (Vocabulary)',
      'type': 'text',
      'duration': 12,
      'content':
          'book — kitob, pen — ruchka, table — stol, water — suv, '
              'house — uy, school — maktab.',
    },
    {
      'title': 'Oraliq nazorat testi',
      'type': 'quiz',
      'duration': 10,
      'content': 'O\'tilgan grammatika va so\'zlar bo\'yicha test.',
      'questions': [
        {
          'question': 'I ___ a student.',
          'options': ['am', 'is', 'are', 'be'],
          'correctIndex': 0,
        },
        {
          'question': 'She ___ to school every day.',
          'options': ['go', 'goes', 'going', 'went'],
          'correctIndex': 1,
        },
        {
          'question': '"Kitob" inglizcha qanday?',
          'options': ['Pen', 'Book', 'Table', 'Door'],
          'correctIndex': 1,
        },
      ],
    },
    {
      'title': 'Past Simple zamoni',
      'type': 'text',
      'duration': 15,
      'content':
          'O\'tgan zamon: I worked, She played. Ko\'p fe\'llarga -ed '
              'qo\'shiladi. Notog\'ri fe\'llar: go → went, see → saw.',
    },
    {
      'title': 'Yakuniy imtihon',
      'type': 'quiz',
      'duration': 15,
      'content': 'Butun kurs bo\'yicha yakuniy test.',
      'questions': [
        {
          'question': 'They ___ happy yesterday.',
          'options': ['is', 'was', 'were', 'are'],
          'correctIndex': 2,
        },
        {
          'question': 'Past Simple of "go"?',
          'options': ['goed', 'gone', 'went', 'going'],
          'correctIndex': 2,
        },
        {
          'question': '"Maktab" inglizcha qanday?',
          'options': ['House', 'School', 'Street', 'City'],
          'correctIndex': 1,
        },
      ],
    },
  ];

  // ─── Matematika paketi ──────────────────────────────────────────────────────
  static const _mathPack = [
    {
      'title': 'Natural sonlar',
      'type': 'video',
      'duration': 10,
      'content':
          '1, 2, 3, 4 ... sanash uchun ishlatiladigan sonlar. '
              'Ularning xossalari bilan tanishamiz.',
    },
    {
      'title': 'Qo\'shish va ayirish',
      'type': 'text',
      'duration': 12,
      'content': 'Misol: 25 + 17 = 42, 50 − 23 = 27. Amallar tartibi muhim.',
    },
    {
      'title': 'Ko\'paytirish va bo\'lish',
      'type': 'text',
      'duration': 14,
      'content':
          'Misol: 6 × 7 = 42, 56 ÷ 8 = 7. Ko\'paytirish jadvalini '
              'yaxshi bilish kerak.',
    },
    {
      'title': 'Amallar tartibi',
      'type': 'text',
      'duration': 13,
      'content':
          'Avval qavs, keyin ko\'paytirish/bo\'lish, so\'ng '
              'qo\'shish/ayirish. Misol: 2 + 2 × 2 = 6.',
    },
    {
      'title': 'Kasrlar',
      'type': 'video',
      'duration': 15,
      'content': '1/2, 3/4 — butunning bo\'laklari. 1/2 + 1/2 = 1.',
    },
    {
      'title': 'Tenglamalar',
      'type': 'text',
      'duration': 16,
      'content': 'x + 5 = 12 → x = 7. Noma\'lumni topish asoslari.',
    },
    {
      'title': 'Oraliq nazorat testi',
      'type': 'quiz',
      'duration': 10,
      'content': 'Hisoblash ko\'nikmalaringizni tekshiring.',
      'questions': [
        {
          'question': '2 + 2 × 2 = ?',
          'options': ['6', '8', '4', '10'],
          'correctIndex': 0,
        },
        {
          'question': '1/2 + 1/2 = ?',
          'options': ['1', '1/4', '2', '0'],
          'correctIndex': 0,
        },
        {
          'question': '56 ÷ 8 = ?',
          'options': ['6', '7', '8', '9'],
          'correctIndex': 1,
        },
      ],
    },
    {
      'title': 'Foizlar',
      'type': 'text',
      'duration': 14,
      'content': '100 ning 20% = 20. Foiz — yuzdan bo\'lakni bildiradi.',
    },
    {
      'title': 'Yakuniy imtihon',
      'type': 'quiz',
      'duration': 15,
      'content': 'Butun kurs bo\'yicha yakuniy test.',
      'questions': [
        {
          'question': 'x + 5 = 12 bo\'lsa, x = ?',
          'options': ['5', '7', '17', '12'],
          'correctIndex': 1,
        },
        {
          'question': 'To\'g\'ri burchak necha gradus?',
          'options': ['45', '90', '180', '60'],
          'correctIndex': 1,
        },
        {
          'question': '200 ning 10% qancha?',
          'options': ['10', '20', '2', '200'],
          'correctIndex': 1,
        },
      ],
    },
  ];

  // ─── Umumiy paket (mavzu aniqlanmasa) ──────────────────────────────────────
  static const _defaultPack = [
    {
      'title': 'Kirish va kurs bilan tanishuv',
      'type': 'video',
      'duration': 8,
      'content':
          'Kursda nimalarni o\'rganasiz, tuzilishi va baholash mezonlari.',
    },
    {
      'title': 'Asosiy tushunchalar',
      'type': 'text',
      'duration': 12,
      'content': 'Mavzuning tayanch atamalari va tushunchalari bilan tanishuv.',
    },
    {
      'title': 'Birinchi amaliy mashg\'ulot',
      'type': 'text',
      'duration': 15,
      'content': 'Nazariyani amaliyotda qo\'llash, bosqichma-bosqich misollar.',
    },
    {
      'title': 'Misollar va tahlil',
      'type': 'text',
      'duration': 14,
      'content': 'Hayotiy misollar yordamida tushunchalarni mustahkamlaymiz.',
    },
    {
      'title': 'Oraliq nazorat testi',
      'type': 'quiz',
      'duration': 10,
      'content': 'O\'tilgan mavzular bo\'yicha bilimingizni tekshiring.',
      'questions': [
        {
          'question': 'Amaliy mashg\'ulot nima uchun muhim?',
          'options': [
            'Vaqt o\'tkazish uchun',
            'Ko\'nikma hosil qilish uchun',
            'Majburiy bo\'lgani uchun',
            'Muhim emas',
          ],
          'correctIndex': 1,
        },
        {
          'question': 'Takrorlash qanday foyda beradi?',
          'options': [
            'Hech qanday',
            'Vaqtni oladi',
            'Bilimni mustahkamlaydi',
            'Chalkashtiradi',
          ],
          'correctIndex': 2,
        },
      ],
    },
    {
      'title': 'Chuqurlashtirilgan mavzu',
      'type': 'video',
      'duration': 18,
      'content': 'Murakkabroq holatlar va ularni yechish usullari.',
    },
    {
      'title': 'Amaliy loyiha',
      'type': 'text',
      'duration': 20,
      'content': 'Bilimlarni birlashtirib kichik loyiha ustida ishlaymiz.',
    },
    {
      'title': 'Yakuniy imtihon',
      'type': 'quiz',
      'duration': 15,
      'content': 'Butun kurs bo\'yicha yakuniy baholash.',
      'questions': [
        {
          'question': 'Kursni muvaffaqiyatli tugatish uchun nima kerak?',
          'options': [
            'Darslarni muntazam o\'rganish',
            'Hech narsa',
            'Faqat oxirgi kuni',
            'Boshqalardan ko\'chirish',
          ],
          'correctIndex': 0,
        },
      ],
    },
  ];

  /// Kurs nomiga qarab mos dars paketini tanlaydi.
  List<Map<String, dynamic>> _packForTitle(String title) {
    final t = title.toLowerCase();
    bool has(List<String> kw) => kw.any(t.contains);

    if (has(['dastur', 'program', 'python', 'kod', 'code', 'flutter',
        'dart', 'java', 'web', 'it '])) {
      return _programmingPack;
    }
    if (has(['ingliz', 'english', 'til', 'language', 'german', 'rus tili'])) {
      return _englishPack;
    }
    if (has(['matematik', 'math', 'algebra', 'geometr', 'hisob', 'arifmetik'])) {
      return _mathPack;
    }
    return _defaultPack;
  }

  /// Kursni realistik darslar va o'quvchi progressi bilan to'ldiradi.
  /// Eski demo ma'lumotni o'chirib, yangidan yozadi (idempotent).
  Future<({int lessons, int students})> seedRealisticContent({
    required String courseId,
    required String courseTitle,
    int studentCount = 15,
  }) async {
    final rnd = Random(courseId.hashCode & 0x7fffffff);
    final now = DateTime.now();
    final pack = _packForTitle(courseTitle);

    // 1. Eski demo ma'lumotni tozalaymiz (dublikat bo'lmasligi uchun).
    await clearCourseDemo(courseId);
    await _clearDemoLessons(courseId);

    // 2. Kursda mavjud (o'qituvchi yaratgan) haqiqiy darslar.
    final existingSnap = await _db
        .collection(AppConstants.lessonsCollection)
        .where('courseId', isEqualTo: courseId)
        .get();
    final existing = existingSnap.docs
        .map((d) => (
              id: d.id,
              order: (d.data()['orderIndex'] as num?)?.toInt() ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // 3. Demo darslarni yaratamiz.
    final lessonsCol = _db.collection(AppConstants.lessonsCollection);
    final lessonBatch = _db.batch();
    final createdIds = <String>[];
    final startOrder = existing.length;
    for (var i = 0; i < pack.length; i++) {
      final t = pack[i];
      final type = t['type'] as String;
      final ref = lessonsCol.doc();
      createdIds.add(ref.id);
      lessonBatch.set(ref, {
        'courseId': courseId,
        'title': t['title'],
        'content': t['content'],
        'type': type,
        'orderIndex': startOrder + i,
        'durationMinutes': t['duration'],
        'createdAt': Timestamp.fromDate(
            now.subtract(Duration(days: 230 - i * 3))),
        'videoUrl': type == 'video'
            ? 'https://www.youtube.com/watch?v=demo'
            : null,
        'questions': type == 'quiz' ? (t['questions'] ?? const []) : const [],
        'isDemo': true,
      });
    }
    await lessonBatch.commit();

    // 4. Barcha darslar tartib bo'yicha (mavjud + yangi).
    final allLessonIds = [...existing.map((e) => e.id), ...createdIds];
    final total = allLessonIds.length;

    // 5. Kursdagi umumiy darslar sonini yangilaymiz.
    await _db
        .collection(AppConstants.coursesCollection)
        .doc(courseId)
        .update({'totalLessons': total});

    // 6. O'quvchilarni darslarga bog'lab yozamiz.
    final students = await _seedStudents(
      courseId: courseId,
      lessonIds: allLessonIds,
      count: studentCount,
      rnd: rnd,
      now: now,
    );

    return (lessons: createdIds.length, students: students);
  }

  Future<int> _seedStudents({
    required String courseId,
    required List<String> lessonIds,
    required int count,
    required Random rnd,
    required DateTime now,
  }) async {
    final total = lessonIds.isEmpty ? 1 : lessonIds.length;
    final names = List<String>.from(_names)..shuffle(rnd);
    final col = _db.collection(AppConstants.progressCollection);
    final batch = _db.batch();

    final n = count.clamp(1, names.length);
    for (var i = 0; i < n; i++) {
      final isLow = i % 4 == 0;
      final completed = isLow
          ? rnd.nextInt((total * 0.35).ceil().clamp(1, total))
          : (total * (0.45 + rnd.nextDouble() * 0.55)).round().clamp(0, total);

      // Ro'yxatga olingan sana (200..360 kun oldin).
      final enrolledAt =
          now.subtract(Duration(days: 200 + rnd.nextInt(160)));
      final spanDays = now.difference(enrolledAt).inDays.clamp(1, 10000);

      // Darslarni TARTIB bilan tugatadi (realistik), vaqt taqsimlanadi —
      // faol o'quvchining oxirgi darslari yaqin kunlarda tugaydi.
      final lessonProgresses = <Map<String, dynamic>>[];
      for (var l = 0; l < completed; l++) {
        final frac = completed == 0 ? 1.0 : (l + 1) / completed;
        var dayOffset = (spanDays * frac).round() - rnd.nextInt(4);
        dayOffset = dayOffset.clamp(0, spanDays);
        final ts = enrolledAt.add(
          Duration(days: dayOffset, hours: rnd.nextInt(24)),
        );
        final score = isLow ? 25 + rnd.nextInt(30) : 60 + rnd.nextInt(40);
        lessonProgresses.add({
          'lessonId': lessonIds[l],
          'isCompleted': true,
          'completedAt': Timestamp.fromDate(ts),
          'score': score,
        });
      }

      final lastActive = isLow
          ? now.subtract(Duration(days: 7 + rnd.nextInt(20)))
          : now.subtract(Duration(days: rnd.nextInt(4), hours: rnd.nextInt(24)));

      final doc = col.doc();
      batch.set(doc, {
        'studentId': 'demo_${doc.id}',
        'studentName': names[i],
        'courseId': courseId,
        'lessonProgresses': lessonProgresses,
        'lastActiveAt': Timestamp.fromDate(lastActive),
        'enrolledAt': Timestamp.fromDate(enrolledAt),
        'isDemo': true,
      });
    }

    await batch.commit();
    return n;
  }

  /// 2 ta yangi demo kurs yaratadi va realistik ma'lumot bilan to'ldiradi.
  Future<({int courses, int lessons, int students})> createDemoCourses({
    required String teacherId,
    required String teacherName,
  }) async {
    final specs = [
      (
        'Python dasturlash asoslari',
        'Noldan boshlab Python: o\'zgaruvchilar, tsikllar, funksiyalar va amaliy loyiha.',
      ),
      (
        'Ingliz tili A1 (Boshlang\'ich)',
        'Inglizcha alifbo, salomlashish, asosiy grammatika va kundalik so\'zlar.',
      ),
    ];

    final coursesCol = _db.collection(AppConstants.coursesCollection);
    var lessons = 0;
    var students = 0;
    final now = DateTime.now();

    for (final s in specs) {
      final ref = await coursesCol.add({
        'title': s.$1,
        'description': s.$2,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'totalLessons': 0,
        'createdAt': Timestamp.fromDate(now),
        'isActive': true,
        'isDemo': true,
      });
      final r =
          await seedRealisticContent(courseId: ref.id, courseTitle: s.$1);
      lessons += r.lessons;
      students += r.students;
    }

    return (courses: specs.length, lessons: lessons, students: students);
  }

  /// Barcha demo ma'lumotni o'chiradi: demo darslar, demo o'quvchilar va
  /// demo kurslar. Real kurslarning dars soni qayta hisoblanadi.
  Future<({int lessons, int progress, int courses})> clearAllDemo() async {
    final lessonsSnap = await _db
        .collection(AppConstants.lessonsCollection)
        .where('isDemo', isEqualTo: true)
        .get();
    final progressSnap = await _db
        .collection(AppConstants.progressCollection)
        .where('isDemo', isEqualTo: true)
        .get();
    final coursesSnap = await _db
        .collection(AppConstants.coursesCollection)
        .where('isDemo', isEqualTo: true)
        .get();

    final demoCourseIds = coursesSnap.docs.map((d) => d.id).toSet();
    // Demo dars qo'shilgan REAL kurslar (demo kurslar bundan mustasno).
    final affected = lessonsSnap.docs
        .map((d) => d.data()['courseId'] as String?)
        .whereType<String>()
        .toSet()
        .difference(demoCourseIds);

    final l = await _deleteAll(lessonsSnap.docs);
    final p = await _deleteAll(progressSnap.docs);
    final c = await _deleteAll(coursesSnap.docs);

    // Real kurslarda qolgan haqiqiy darslar sonini tiklaymiz.
    for (final cid in affected) {
      final remaining = await _db
          .collection(AppConstants.lessonsCollection)
          .where('courseId', isEqualTo: cid)
          .get();
      await _db
          .collection(AppConstants.coursesCollection)
          .doc(cid)
          .update({'totalLessons': remaining.docs.length});
    }

    return (lessons: l, progress: p, courses: c);
  }

  /// Kursdagi demo o'quvchi hujjatlarini o'chiradi.
  Future<int> clearCourseDemo(String courseId) async {
    final snap = await _db
        .collection(AppConstants.progressCollection)
        .where('courseId', isEqualTo: courseId)
        .where('isDemo', isEqualTo: true)
        .get();
    return _deleteAll(snap.docs);
  }

  Future<int> _clearDemoLessons(String courseId) async {
    final snap = await _db
        .collection(AppConstants.lessonsCollection)
        .where('courseId', isEqualTo: courseId)
        .where('isDemo', isEqualTo: true)
        .get();
    return _deleteAll(snap.docs);
  }

  Future<int> _deleteAll(List<QueryDocumentSnapshot> docs) async {
    final batch = _db.batch();
    for (final d in docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    return docs.length;
  }
}
