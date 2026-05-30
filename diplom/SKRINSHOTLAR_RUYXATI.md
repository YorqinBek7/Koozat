# Skrinshotlar ro'yxati

Quyidagi skrinshotlarni `diplom/rasmlar/` papkasiga, ko'rsatilgan nom bilan saqlash kerak.

**Tavsiyalar:**
- iPhone/Android simulatordan yoki haqiqiy qurilmadan oling
- Bir xil device frame (masalan, hammasi iPhone 14 Pro) ishlatish chiroyli ko'rinadi
- PNG formatida, ~1080–1290px keng, oq fon
- Status bar (vaqt, batareya) tozalangan bo'lsa yaxshi (`xcrun simctl status_bar override` yoki rasm tahriri bilan)

---

## II BOB skrinshot­lari

| Fayl nomi | Tavsif | Qayerda ishlatiladi |
|---|---|---|
| `2_1_arxitektura.png` | Tizimning umumiy arxitektura sxemasi (4 qatlam: Presentation, Domain, Data, Cloud). Diagram dasturida (draw.io, Figma) chizib eksport qiling | 2.1.2-bo'lim |
| `2_2_firestore_struktura.png` | Cloud Firestore collection tuzilmasi (users, courses, lessons, attendance, grades). Firebase Console skrinshoti yoki diagram | 2.2.1-bo'lim |
| `2_3_splash.png` | Splash screen — ilova ochilish ekrani | 2.2.2-bo'lim |
| `2_4_login.png` | Login ekrani | 2.2.2-bo'lim |
| `2_5_register.png` | Ro'yxatdan o'tish ekrani (rol tanlash: talaba/o'qituvchi) | 2.2.2-bo'lim |
| `2_6_teacher_home.png` | O'qituvchi bosh sahifasi (statistika kartalari, live activity) | 2.3.1-bo'lim |
| `2_7_student_home.png` | Talaba bosh sahifasi (kurslar progressi) | 2.3.1-bo'lim |
| `2_8_courses_list.png` | Kurslar ro'yxati ekrani | 2.3.1-bo'lim |
| `2_9_course_detail.png` | Bitta kursning batafsil sahifasi (darslar, talabalar) | 2.3.1-bo'lim |
| `2_10_create_course.png` | Yangi kurs yaratish formasi | 2.3.2-bo'lim |
| `2_11_analytics.png` | Analitika ekrani (chart, grafiklar bilan) | 2.3.2-bo'lim |
| `2_12_navigation.png` | Bottom navigation bar / menyu strukturasi | 2.3.2-bo'lim |

## III BOB skrinshot­lari

| Fayl nomi | Tavsif | Qayerda ishlatiladi |
|---|---|---|
| `3_1_realtime_demo.png` | Real vaqtli yangilanish demonstratsiyasi (ikkita qurilma yonma-yon — o'qituvchi baho qo'yadi, talaba ekranida darhol ko'rinadi) | 3.1-bo'lim |
| `3_2_chart_progress.png` | Talabaning progress chart-i (fl_chart bilan chizilgan grafik) | 3.2-bo'lim |
| `3_3_attendance_stat.png` | Davomat statistikasi (foiz ko'rsatkichi, percent indicator) | 3.2-bo'lim |
| `3_4_grade_distribution.png` | Baholar taqsimoti diagrammasi | 3.2-bo'lim |
| `3_5_risk_students.png` | "Xavf zonasi"dagi talabalar ro'yxati (agar mavjud bo'lsa) | 3.2-bo'lim |

## Diagram skrinshot­lari (diagram tools bilan)

| Fayl nomi | Tavsif |
|---|---|
| `2_1_arxitektura.png` | Yuqorida qayd etilgan |
| `2_13_data_flow.png` | Ma'lumot oqim diagrammasi (talaba harakat → Firestore → o'qituvchi UI) |
| `2_14_clean_arch.png` | Clean Architecture qatlamlari diagrammasi |
| `2_15_uml_class.png` | UML class diagram — User, Course, Lesson, Attendance, Grade modellari |

---

## Skrinshotlarni qanday olish

### iOS Simulator
```bash
# Simulatorni ishga tushiring
cd /Users/yorqin/Documents/Projects/koozat
flutter run -d "iPhone 15 Pro"

# Skrinshot olish: Cmd+S (Simulator menu: File → Save Screen)
# Yoki terminal orqali:
xcrun simctl io booted screenshot ~/Downloads/skrinshot.png
```

### Android Emulator
```bash
flutter run -d emulator-5554
# Emulator panelida camera tugmasi
```

### Web (chrome) skrinshotlar uchun
```bash
flutter run -d chrome
# Brauzerda Cmd+Shift+5 (macOS) yoki PrtSc (Linux/Windows)
```

### Status bar tozalash (iOS)
```bash
xcrun simctl status_bar booted override --time "9:41" --batteryLevel 100 --wifiBars 3 --cellularBars 4
```
