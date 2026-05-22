// ==============================
// ملف الأحجام والمسافات
// اسم الملف: app_sizes.dart
// المكان: lib/core/constants/
//
// كل الأحجام في مكان واحد
// يضمن إن اللعبة تبدو صح على كل الشاشات
// موبايل، آيباد، ويب
// ==============================

abstract class AppSizes {

  // ==============================
  // المسافات الأساسية
  // تستخدم في SizedBox و Padding
  // ==============================

  // مسافة صغيرة جداً — بين الأيقونة والنص
  static const double spaceXS = 4.0;

  // مسافة صغيرة — بين العناصر المتقاربة
  static const double spaceSM = 8.0;

  // مسافة متوسطة — الاستخدام العام
  static const double spaceMD = 16.0;

  // مسافة كبيرة — بين الأقسام
  static const double spaceLG = 24.0;

  // مسافة كبيرة جداً — بين الشاشات
  static const double spaceXL = 32.0;

  // مسافة ضخمة — للعناصر الرئيسية
  static const double spaceXXL = 48.0;

  // ==============================
  // أحجام الخطوط
  // ==============================

  // خط صغير جداً — تفاصيل صغيرة
  static const double fontXS = 10.0;

  // خط صغير — النصوص الثانوية
  static const double fontSM = 12.0;

  // خط متوسط — النصوص العادية
  static const double fontMD = 14.0;

  // خط كبير — النصوص الأساسية
  static const double fontLG = 16.0;

  // خط كبير جداً — العناوين
  static const double fontXL = 20.0;

  // خط ضخم — عنوان السؤال
  static const double fontXXL = 24.0;

  // خط اسم اللعبة
  static const double fontTitle = 42.0;

  // ==============================
  // أحجام الأيقونات
  // ==============================

  // أيقونة صغيرة
  static const double iconSM = 24.0;

  // أيقونة متوسطة
  static const double iconMD = 48.0;

  // أيقونة كبيرة — الشاشة الرئيسية
  static const double iconLG = 100.0;

  // ==============================
  // زوايا البطاقات والأزرار
  // BorderRadius.circular() يستخدمها
  // ==============================

  // زاوية صغيرة — للعناصر الصغيرة
  static const double radiusSM = 8.0;

  // زاوية متوسطة — للأزرار
  static const double radiusMD = 16.0;

  // زاوية كبيرة — للبطاقات
  static const double radiusLG = 20.0;

  // زاوية دائرية كاملة — للشارات
  static const double radiusFull = 100.0;

  // ==============================
  // أحجام الأزرار
  // ==============================

  // ارتفاع الزر الأساسي
  static const double buttonHeight = 56.0;

  // عرض الزر الأساسي
  static const double buttonWidth = 200.0;

  // padding داخل الزر — أفقي
  static const double buttonPaddingH = 48.0;

  // padding داخل الزر — عمودي
  static const double buttonPaddingV = 16.0;

  // ==============================
  // أحجام بطاقة السؤال
  // ==============================

  // ارتفاع بطاقة السؤال
  static const double questionCardHeight = 160.0;

  // padding داخل البطاقة
  static const double questionCardPadding = 24.0;

  // ==============================
  // أحجام بطاقة الإجابة
  // ==============================

  // ارتفاع زر الإجابة
  static const double answerButtonHeight = 64.0;

  // padding داخل زر الإجابة
  static const double answerButtonPadding = 16.0;

  // ==============================
  // المؤقت — الدائرة
  // ==============================

  // حجم دائرة المؤقت
  static const double timerSize = 80.0;

  // سماكة خط الدائرة
  static const double timerStrokeWidth = 6.0;

  // ==============================
  // الشاشات — نقاط التحول
  // Responsive Design
  // ==============================

  // الحد الأدنى للموبايل
  static const double mobileMaxWidth = 600.0;

  // الحد الأدنى للتابلت
  static const double tabletMaxWidth = 1024.0;

  // الحد الأقصى لعرض المحتوى في الويب
  static const double webMaxWidth = 800.0;
}