// ==============================
// نموذج السؤال
// اسم الملف: question_model.dart
// المكان: lib/data/models/
// ==============================

class QuestionModel {

  // رقم تعريفي فريد
  final String id;

  // نص السؤال
  final String question;

  // قائمة الخيارات — فاضية للأسئلة المفتوحة
  final List<String> options;

  // رقم الإجابة الصحيحة — للأسئلة ذات الخيارات
  final int correctIndex;

  // المستوى — ١، ٢، أو ٣
  final int level;

  // النقاط — ٢٠٠، ٤٠٠، أو ٦٠٠
  final int points;

  // رقم الفئة
  final String categoryId;

  // رابط صورة — اختياري
  final String? imageUrl;

  // رابط فيديو — اختياري
  final String? videoUrl;

  // الوقت بالثواني — افتراضي ١٢٠
  final int timeLimitSeconds;

  // ==============================
  // الإجابة النصية — للأسئلة المفتوحة
  // مثل: 'أبو بكر الصديق'
  // ==============================
  final String? answer;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.level,
    required this.points,
    required this.categoryId,
    this.imageUrl,
    this.videoUrl,
    this.timeLimitSeconds = 120,
    this.answer, // اختياري
  });

  // ==============================
  // هل السؤال مفتوح؟
  // يعني ما عنده خيارات
  // ==============================
  bool get isOpenQuestion => options.isEmpty;

  // ==============================
  // دالة للتحقق من الإجابة
  // ==============================
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  // ==============================
  // نقاط حسب المستوى
  // ==============================
  static int getPointsByLevel(int level) {
    switch (level) {
      case 1: return 200;
      case 2: return 400;
      case 3: return 600;
      default: return 200;
    }
  }
}