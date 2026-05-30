# UMUMIY XULOSA

Mazkur diplom loyihasida talabalarning o‘quv jarayonini real vaqt rejimida monitoring qiluvchi “Koozat” analitika tizimini ilmiy asoslangan tarzda loyihalash, dasturiy ta’minotini ishlab chiqish va uning samaradorligini empirik baholash bo‘yicha to‘liq tadqiqot ishlari amalga oshirildi. Olib borilgan ishlar natijasida quyidagi yakuniy xulosalar shakllantirildi:

**1. Mavzuning dolzarbligi nazariy jihatdan asoslandi.** I bobda olib borilgan tahlil shuni ko‘rsatdiki, zamonaviy ta’lim tizimi ma’lumotlarga asoslangan boshqaruvga o‘tib bormoqda va o‘quv analitikasi (Learning Analytics) bu o‘tishning markaziy bo‘g‘inini tashkil etadi. An’anaviy davriy nazoratga asoslangan baholash modelining asosiy kamchiligi — kechikkan reaksiya va individuallashtirilmagan yondashuv — real vaqtli monitoring orqali samarali bartaraf etiladi. Xalqaro tadqiqotlar (Purdue Signals, OU Analyse) real vaqtli ogohlantirish tizimlari talabalarning muvaffaqiyatli yakunlash darajasini sezilarli darajada oshirishini isbotlagan.

**2. Asosiy o‘quv ko‘rsatkichlari va ularning kompozit indekslari ishlab chiqildi.** Davomat, baholar va faollik kabi alohida ko‘rsatkichlardan tashqari, ularning sintezi sifatida ikkita kompozit indeks taklif etildi: **Umumiy Progress Indeksi (UPI = 0,30·Davomat + 0,50·Baho + 0,20·Faollik)** va **Risk Indeksi (RI)**. Bu ko‘rsatkichlar talabaning umumiy holatini bir o‘lchovga keltirish va xavfli holatlarni avtomatik aniqlashga imkon beradi.

**3. Mavjud LMS-tizimlarning qiyosiy tahlili o‘tkazildi.** Moodle, Google Classroom va Canvas kabi yetakchi platformalarning afzalliklari va kamchiliklari aniqlandi. Asosiy kamchiliklar: kontentga yo‘naltirilganlik (analitika ikkinchi darajada), statik hisobotlar, mobil moslashuvchanlikning yetishmasligi, real vaqtli sinxronizatsiya yo‘qligi. Bu kamchiliklar “Koozat” tizimini loyihalashda asosiy yo‘naltiruvchi sifatida ishlatildi.

**4. Tizim arxitekturasi ilmiy asoslangan tarzda tanlandi.** *Serverless / BaaS* arxitekturasi va Clean Architecture tamoyillari asosida to‘rt qatlamli model (Presentation → Domain → Data → Cloud Infrastructure) ishlab chiqildi. Texnologiyalar steki sifatida **Flutter (Dart)** va **Firebase to‘plami** (Authentication, Cloud Firestore, Cloud Functions, Cloud Messaging, Hosting) tanlandi.

**5. “Koozat” tizimining dasturiy ta’minoti to‘liq ishlab chiqildi.** Tizim quyidagi asosiy modullarni o‘z ichiga oladi: autentifikatsiya (email/parol va Google Sign-In), rolga asoslangan kirish (talaba/o‘qituvchi/administrator), real vaqtli ma’lumotlar oqimini boshqarish (Firestore Streams + Riverpod StreamProvider), Cloud Functions orqali fon hisob-kitoblari (UPI, RI), push-bildirishnomalar va vizual analitika ekranlari.

**6. UI/UX dizayni xalqaro standartlarga muvofiq amalga oshirildi.** *User-Centered Design*, Material Design 3 va WCAG 2.1 AA standartlari asosida foydalanuvchiga qulay, intuitiv va keng auditoriyaga moslashtirilgan interfeys yaratildi. Uchta tilda lokalizatsiya (o‘zbek lotin, rus, ingliz) qo‘llab-quvvatlanadi.

**7. Tizimning ta’lim sifatiga ijobiy ta’siri empirik tasdiqlandi.** Muhammad al-Xorazmiy nomidagi TATUning AKT sohasida kasb ta’limi fakultetida o‘tkazilgan 12 haftalik kvazi-eksperimental sinov natijasida quyidagi statistik jihatdan ahamiyatli o‘zgarishlar qayd etildi:

   - Davomat darajasi **+6,8 foiz punkt** (84,2 % → 91,0 %), *t* = 5,17, *p* < 0,001;
   - O‘rtacha yakuniy baho **+6,7 ball** (68,4 → 75,1), *t* = 1,87, *p* = 0,034, Cohen’s d = 0,54;
   - Xavf zonasidagi talabalar ulushi **5 baravar** kamaydi (20,8 % → 4,2 %), χ² = 4,18, *p* = 0,041;
   - O‘qituvchi-talaba aloqa chastotasi **4,25 baravar** oshdi, *U* = 18, *p* < 0,001;
   - Pedagogik aralashuv kechikishi **14 kundan 1,8 kungacha** qisqardi (7,8 baravar tezroq);
   - Foydalanuvchi qoniqishi: talabalar 4,42/5, o‘qituvchilar 4,70/5; NPS = 81 %.

**8. Tizimning afzalliklari va kamchiliklari aniqlandi.** Asosiy afzalliklar — haqiqiy real vaqtli sinxronizatsiya, mobil-birinchi yondashuv, sodda lekin kuchli analitika, o‘zbek tiliga to‘liq lokalizatsiya, past joriy etish to‘sig‘i va iqtisodiy samaradorligi. Asosiy cheklovlar — internetga bog‘liqlik, *vendor lock-in* xavfi, kichik testlash sirti, adaptiv ta’lim mexanizmlarining yo‘qligi.

**9. Rivojlantirish yo‘l xaritasi ishlab chiqildi.** Uch bosqichli rivojlanish dasturi taklif etildi: qisqa muddatli (2026 yil 1-yarmi) — geymifikatsiya, roditellar paneli, kengaytirilgan sinov; o‘rta muddatli (2026 yil 2-yarmi – 2027) — AI-prediktiv analitika, adaptiv tavsiyalar; uzoq muddatli (2028+) — multitenancy SaaS, self-hosted variant, xalqaro bozor.

**10. Hayot faoliyati xavfsizligi talablari to‘liq amalga oshirildi.** IV bobda ko‘rib chiqilgan ergonomika, elektr va yong‘in xavfsizligi qoidalari (SanQoidM № 0325-16, ISO 9241-5, PUE) loyihani ishlab chiqish jarayonida to‘liq hisobga olindi va amaliyotda qo‘llanildi.

**Tadqiqotning ilmiy yangiligi** — *Backend-as-a-Service* arxitekturasi (Firebase) asosida real vaqtli o‘quv analitikasi tizimini qurishning to‘liq metodologiyasi taklif etildi va empirik tasdiqlandi. UPI va Risk Indeksi kabi kompozit ko‘rsatkichlar formulalari va ularning vazn koeffitsiyentlari nazariy asoslandi.

**Tadqiqotning amaliy ahamiyati** — ishlab chiqilgan “Koozat” tizimi oliy va o‘rta maxsus ta’lim muassasalarida, shuningdek, o‘quv markazlari va onlayn kurslar platformalarida amaliyotda qo‘llanilishi mumkin. Sinov natijalari tizimning ta’lim sifatiga real ijobiy ta’sirini tasdiqlaydi.

**Tavsiyalar.** Olib borilgan tadqiqot natijalari asosida quyidagi tavsiyalar shakllantirildi:

1. Ta’lim muassasalariga zamonaviy ma’lumotlarga asoslangan boshqaruv tizimlarini joriy etishni jadallashtirish tavsiya etiladi;
2. “Koozat” tizimini xalqaro va respublika miqyosida kengaytirilgan sinovdan o‘tkazish maqsadga muvofiq;
3. Sun’iy intellekt asosidagi prediktiv analitika moduli ishlab chiqilishi kelajakdagi ustuvor vazifa hisoblanadi;
4. Tizimni HEMIS va boshqa mavjud ta’lim platformalari bilan integratsiyalashtirish to‘g‘risida ishlar olib borilishi kerak;
5. O‘qituvchilarning raqamli savodxonligini oshirishga qaratilgan o‘quv kurslarini tashkillashtirish lozim.

Yakunda shuni ta’kidlash lozimki, ushbu diplom loyihasi davomida olib borilgan tadqiqotlar va ishlab chiqilgan “Koozat” real vaqtli o‘quv analitikasi tizimi belgilangan maqsadlarga to‘liq erishishga imkon berdi. Tizimning real foydalanuvchi muhitidagi sinov natijalari uning ta’limdagi yuqori pedagogik va amaliy qiymatini ishonchli tasdiqladi.
