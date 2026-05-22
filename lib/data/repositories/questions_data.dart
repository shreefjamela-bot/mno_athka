// ==============================
// ملف بيانات الأسئلة التجريبية
// اسم الملف: questions_data.dart
// المكان: lib/data/repositories/
//
// هنا نحط الأسئلة مؤقتاً
// بعدين في المرحلة ٢ تجي من Supabase
// ==============================

import '../models/question_model.dart';

class QuestionsData {

  // ==============================
  // قائمة الأسئلة التجريبية
  // ١٠ أسئلة — قالب معلومات عامة
  // ==============================
  static const List<QuestionModel> questions = [

    // ==============================
    // المستوى الأول — ٢٠٠ نقطة
    // ==============================

    QuestionModel(
      id: 'q1',
      categoryId: 'general',
      level: 1,
      points: 200,
      question: 'ما هي عاصمة المملكة العربية السعودية؟',
      options: ['جدة', 'الرياض', 'مكة المكرمة', 'الدمام'],
      correctIndex: 1, // الرياض
    ),

    QuestionModel(
      id: 'q2',
      categoryId: 'general',
      level: 1,
      points: 200,
      question: 'كم عدد أيام السنة الميلادية؟',
      options: ['354', '365', '360', '366'],
      correctIndex: 1, // 365
    ),

    QuestionModel(
      id: 'q3',
      categoryId: 'general',
      level: 1,
      points: 200,
      question: 'ما هو أكبر محيط في العالم؟',
      options: ['المحيط الهندي', 'المحيط الأطلسي', 'المحيط الهادئ', 'المحيط المتجمد'],
      correctIndex: 2, // المحيط الهادئ
    ),

    QuestionModel(
      id: 'q4',
      categoryId: 'general',
      level: 1,
      points: 200,
      question: 'كم عدد ألوان قوس قزح؟',
      options: ['5', '6', '7', '8'],
      correctIndex: 2, // 7
    ),

    // ==============================
    // المستوى الثاني — ٤٠٠ نقطة
    // ==============================

    QuestionModel(
      id: 'q5',
      categoryId: 'general',
      level: 2,
      points: 400,
      question: 'ما هو أطول نهر في العالم؟',
      options: ['نهر الأمازون', 'نهر النيل', 'نهر المسيسيبي', 'نهر اليانغتسي'],
      correctIndex: 1, // نهر النيل
    ),

    QuestionModel(
      id: 'q6',
      categoryId: 'general',
      level: 2,
      points: 400,
      question: 'في أي سنة بدأت الحرب العالمية الثانية؟',
      options: ['1935', '1937', '1939', '1941'],
      correctIndex: 2, // 1939
    ),

    QuestionModel(
      id: 'q7',
      categoryId: 'general',
      level: 2,
      points: 400,
      question: 'ما هو رمز الذهب في الجدول الدوري؟',
      options: ['Go', 'Gd', 'Au', 'Ag'],
      correctIndex: 2, // Au
    ),

    // ==============================
    // المستوى الثالث — ٦٠٠ نقطة
    // ==============================

    QuestionModel(
      id: 'q8',
      categoryId: 'general',
      level: 3,
      points: 600,
      question: 'ما هي أصغر دولة في العالم مساحةً؟',
      options: ['موناكو', 'سان مارينو', 'الفاتيكان', 'ليختنشتاين'],
      correctIndex: 2, // الفاتيكان
    ),

    QuestionModel(
      id: 'q9',
      categoryId: 'general',
      level: 3,
      points: 600,
      question: 'كم عدد عظام جسم الإنسان البالغ؟',
      options: ['196', '206', '216', '226'],
      correctIndex: 1, // 206
    ),

    QuestionModel(
      id: 'q10',
      categoryId: 'general',
      level: 3,
      points: 600,
      question: 'ما هو أسرع حيوان بري في العالم؟',
      options: ['الأسد', 'النمر', 'الفهد', 'الحصان'],
      correctIndex: 2, // الفهد
    ),

  ];

  // ==============================
  // دالة تجيب أسئلة حسب المستوى
  // تأخذ رقم المستوى وترجع قائمة أسئلته
  // ==============================
  static List<QuestionModel> getByLevel(int level) {
    return questions
        .where((q) => q.level == level)
        .toList();
  }
}