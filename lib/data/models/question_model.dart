// ==============================
// نموذج السؤال
// اسم الملف: question_model.dart
// المكان: lib/data/models/
//
// هذا الكلاس يحدد شكل كل سؤال في اللعبة
// كل سؤال عنده: نص، خيارات، إجابة، نقاط، وقت
// ==============================

class QuestionModel {

  // ==============================
  // المتغيرات — بيانات السؤال
  // final = ما يتغير بعد ما يتحدد
  // ==============================

  // رقم تعريفي فريد لكل سؤال
  final String id;

  // نص السؤال
  final String question;

  // قائمة الخيارات — دايماً ٤ خيارات
  final List<String> options;

  // رقم الإجابة الصحيحة — ٠، ١، ٢، أو ٣
  final int correctIndex;

  // المستوى — ١، ٢، أو ٣
  final int level;

  // النقاط — ٢٠٠، ٤٠٠، أو ٦٠٠
  final int points;

  // رقم القالب — مثل: جغرافيا، تاريخ
  final String categoryId;

  // رابط صورة — اختياري (مو كل سؤال عنده صورة)
  // String? = يقدر يكون null
  final String? imageUrl;

  // رابط فيديو — اختياري
  final String? videoUrl;

  // الوقت بالثواني — افتراضي ١٢٠ ثانية
  final int timeLimitSeconds;

  // ==============================
  // الكونستراكتر — طريقة إنشاء السؤال
  // required = لازم تحطه
  // ==============================
  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.level,
    required this.points,
    required this.categoryId,
    this.imageUrl,        // اختياري
    this.videoUrl,        // اختياري
    this.timeLimitSeconds = 120, // افتراضي ١٢٠ ثانية
  });

  // ==============================
  // دالة مساعدة
  // ترجع النقاط بناءً على المستوى
  // ==============================
  static int getPointsByLevel(int level) {
    // switch = اختار حسب القيمة
    switch (level) {
      case 1:
        return 200; // المستوى الأول
      case 2:
        return 400; // المستوى الثاني
      case 3:
        return 600; // المستوى الثالث
      default:
        return 200; // افتراضي
    }
  }

  // ==============================
  // دالة للتحقق من الإجابة
  // تأخذ رقم الخيار وترجع true أو false
  // ==============================
  bool isCorrect(int selectedIndex) {
    // == للمقارنة بين قيمتين
    return selectedIndex == correctIndex;
  }
}