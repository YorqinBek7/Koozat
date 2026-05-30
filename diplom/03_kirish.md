# KIRISH

**Mavzuning dolzarbligi.** Axborot-kommunikatsiya texnologiyalarining jadal rivojlanishi ta’lim sohasini ham tubdan o‘zgartirmoqda. So‘nggi yillarda O‘zbekiston Respublikasida ta’lim tizimini raqamlashtirish, o‘quv jarayonini avtomatlashtirish va ta’lim sifatini oshirishga qaratilgan keng ko‘lamli islohotlar amalga oshirilmoqda. Jumladan, O‘zbekiston Respublikasi Prezidentining 2020-yil 6-oktabrdagi PF-6079-son “Raqamli O‘zbekiston – 2030” strategiyasini tasdiqlash to‘g‘risidagi farmoni va ta’lim sohasini rivojlantirishga oid bir qator hujjatlar bunga yaqqol misol bo‘la oladi. Bu hujjatlarda ta’lim muassasalarida zamonaviy axborot tizimlarini joriy etish, o‘quv jarayonini ma’lumotlarga asoslangan holda boshqarish ustuvor vazifa sifatida belgilab qo‘yilgan.

An’anaviy ta’lim modelida o‘qituvchi talabalarning o‘zlashtirish darajasi, davomati va faolligini asosan davriy nazorat ishlari va imtihonlar orqali baholaydi. Bunday yondashuvning asosiy kamchiligi shundaki, o‘qituvchi talabaning bilimidagi bo‘shliqlarni yoki o‘zlashtirishdagi pasayishni ko‘pincha juda kech – nazorat natijalari e’lon qilingandan keyingina aniqlaydi. Natijada o‘z vaqtida pedagogik aralashuv (intervensiya) qilish imkoniyati boy beriladi va talabaning o‘quv natijasi pasayib ketadi.

Ushbu muammoni hal etishda **real vaqtli o‘quv analitikasi (real-time learning analytics)** muhim vosita hisoblanadi. Real vaqt rejimida ishlovchi monitoring tizimlari o‘qituvchiga talabalarning o‘quv faoliyati to‘g‘risidagi ma’lumotlarni (kursni o‘zlashtirish foizi, dars yakunlash dinamikasi, faollik) bir zumda taqdim etadi. Bu esa o‘qituvchiga “xavf ostidagi” talabalarni erta aniqlash, ularga individual yondashish va o‘quv jarayoniga operativ tuzatishlar kiritish imkonini beradi.

Hozirgi kunda dunyoda Moodle, Google Classroom, Canvas kabi o‘quv jarayonini boshqarish tizimlari (LMS) keng qo‘llanilmoqda. Biroq bu tizimlarning aksariyati, birinchidan, og‘ir va murakkab veb-platformalar bo‘lib, ko‘proq kontentni boshqarishga yo‘naltirilgan; ikkinchidan, ulardagi analitik hisobotlar ko‘pincha statik bo‘lib, real vaqtda yangilanmaydi; uchinchidan, mobil qurilmalarga to‘liq moslashtirilmagan va sodda, intuitiv interfeysga ega emas. Bu holat o‘qituvchi va talaba uchun kundalik foydalanishda noqulayliklar tug‘diradi.

Shu nuqtai nazardan, zamonaviy, yengil, mobil qurilmalarga moslashgan va real vaqtda ishlovchi o‘quv progressini monitoring qiluvchi analitika tizimini ishlab chiqish dolzarb va amaliy ahamiyatga ega vazifa hisoblanadi. Mazkur diplom loyihasida aynan shunday tizim – **“Koozat”** analitik tizimi – zamonaviy Flutter va Firebase texnologiyalari asosida loyihalashtirilgan va ishlab chiqilgan.

**Muammoning qo‘yilishi.** Mavjud ta’lim platformalarida o‘quv jarayonini real vaqtda, soddalashtirilgan va vizual ko‘rinishda kuzatib borish imkoniyati cheklangan. O‘qituvchilar talabalar progressi to‘g‘risida tezkor va aniq ma’lumotga ega bo‘lmaydi, talabalar esa o‘z o‘quv natijalarini real vaqtda kuzata olmaydi. Demak, real vaqtda ma’lumotlarni sinxronlashtiruvchi, rolga asoslangan (o‘qituvchi/talaba) va vizual analitikani taqdim etuvchi yagona tizimga ehtiyoj mavjud.

**Tadqiqotning maqsadi** – talabalarning o‘quv jarayonini real vaqt rejimida monitoring qiluvchi, o‘qituvchi va talaba uchun qulay interfeysga ega bo‘lgan analitika tizimini loyihalash va dasturiy ta’minotini ishlab chiqishdan iborat.

**Tadqiqot vazifalari.** Belgilangan maqsadga erishish uchun quyidagi vazifalar hal etildi:

1. Real vaqtli monitoringning ta’limdagi o‘rni va ahamiyatini nazariy jihatdan o‘rganish;
2. O‘quv jarayonining asosiy ko‘rsatkichlari (davomat, baholar, faollik) va ularni kuzatish usullarini tahlil qilish;
3. Mavjud o‘quv platformalari (Moodle, Google Classroom) imkoniyatlarini qiyosiy tahlil qilish va kamchiliklarini aniqlash;
4. Ishlab chiqiladigan tizimga qo‘yiladigan funksional va nofunksional talablarni shakllantirish;
5. Tizim arxitekturasini loyihalash va mos texnologiyalarni (Flutter, Firebase) asoslab tanlash;
6. “Koozat” analitik tizimining dasturiy ta’minotini ishlab chiqish;
7. Foydalanuvchi interfeysini (UI/UX) loyihalash va amaliy joriy etish;
8. Tizim samaradorligini statistik ma’lumotlar asosida baholash va uning afzalliklari, kamchiliklari hamda rivojlantirish istiqbollarini belgilash.

**Tadqiqot ob’yekti** – ta’lim muassasalarida o‘quv jarayonini monitoring qilish va boshqarish jarayoni.

**Tadqiqot predmeti** – real vaqtda o‘quv progressini monitoring qiluvchi analitika tizimini loyihalash va ishlab chiqish usullari, vositalari hamda texnologiyalari.

**Tadqiqot usullari.** Ishni bajarishda ilmiy adabiyotlarni tahlil qilish, qiyosiy tahlil, tizimli yondashuv, ob’yektga yo‘naltirilgan dasturlash, UML asosida modellashtirish, prototiplash hamda statistik tahlil usullaridan foydalanildi.

**Ishning ilmiy va amaliy yangiligi.** Ishda real vaqtli ma’lumotlar sinxronizatsiyasiga asoslangan, mobil va veb platformalarda ishlovchi, rolga asoslangan kirish tizimiga ega yengil analitika tizimi taklif etilgan. Mavjud LMS tizimlaridan farqli o‘laroq, tizim Firebase Cloud Firestore’ning real vaqtli imkoniyatlaridan foydalanib, o‘quv ko‘rsatkichlarini kechikishsiz yangilash va vizualizatsiya qilishni ta’minlaydi.

**Ishning amaliy ahamiyati.** Ishlab chiqilgan “Koozat” tizimi oliy va o‘rta maxsus ta’lim muassasalarida, shuningdek, o‘quv markazlari va onlayn kurslar platformalarida o‘quv jarayonini samarali boshqarish, talabalar progressini kuzatish hamda ta’lim sifatini oshirish maqsadida amaliyotda qo‘llanilishi mumkin.

**Diplom loyihasining tuzilishi.** Ish kirish, to‘rtta bob, har bir bob bo‘yicha xulosa, umumiy xulosa, foydalanilgan adabiyotlar ro‘yxati va ilovalardan iborat.

*Birinchi bobda* real vaqtda o‘quv progressini monitoring qilishning funksional tahlili keltirilgan: monitoringning ta’limdagi ahamiyati, o‘quv jarayonining asosiy ko‘rsatkichlari va mavjud tizimlarning (Moodle, Google Classroom va boshq.) imkoniyatlari tahlili bayon etilgan.

*Ikkinchi bobda* tizim arxitekturasi va texnologiyalar tanlovi, “Koozat” analitik tizimini Flutter va Firebase yordamida ishlab chiqish hamda foydalanuvchi interfeysini (UI/UX) amaliy joriy etish masalalari yoritilgan.

*Uchinchi bobda* analitika tizimining samaradorligi va statistik tahlili — tizimni joriy etishning ta’lim sifatiga ta’siri, statistik ma’lumotlar asosidagi tahlil va natijalarni baholash, hamda tizimning afzalliklari, kamchiliklari va rivojlantirish istiqbollari ko‘rib chiqilgan.

*To‘rtinchi bobda* hayot faoliyati xavfsizligiga oid masalalar – kompyuter bilan ishlash joyini ergonomik tashkil etish, elektr va yong‘in xavfsizligi qoidalari yoritilgan.
