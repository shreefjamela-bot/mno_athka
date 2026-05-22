// ==============================
// ملف بيانات الأسئلة
// اسم الملف: questions_data.dart
// المكان: lib/data/repositories/
// ==============================

import '../models/question_model.dart';

class QuestionsData {

  static const List<QuestionModel> questions = [

    // ==============================
    // فئة: معلومات عامة — general
    // ==============================

    QuestionModel(
      id: 'g1', categoryId: 'general', level: 1, points: 200,
      question: 'ما هي عاصمة المملكة العربية السعودية؟',
      options: ['جدة', 'الرياض', 'مكة المكرمة', 'الدمام'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 'g2', categoryId: 'general', level: 1, points: 200,
      question: 'كم عدد أيام السنة الميلادية؟',
      options: ['354', '365', '360', '366'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 'g3', categoryId: 'general', level: 1, points: 200,
      question: 'ما هو أكبر محيط في العالم؟',
      options: ['المحيط الهندي', 'المحيط الأطلسي', 'المحيط الهادئ', 'المحيط المتجمد'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'g4', categoryId: 'general', level: 2, points: 400,
      question: 'ما هو أطول نهر في العالم؟',
      options: ['نهر الأمازون', 'نهر النيل', 'نهر المسيسيبي', 'نهر اليانغتسي'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 'g5', categoryId: 'general', level: 2, points: 400,
      question: 'ما هو رمز الذهب في الجدول الدوري؟',
      options: ['Go', 'Gd', 'Au', 'Ag'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'g6', categoryId: 'general', level: 3, points: 600,
      question: 'ما هي أصغر دولة في العالم مساحةً؟',
      options: ['موناكو', 'سان مارينو', 'الفاتيكان', 'ليختنشتاين'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'g7', categoryId: 'general', level: 3, points: 600,
      question: 'كم عدد عظام جسم الإنسان البالغ؟',
      options: ['196', '206', '216', '226'],
      correctIndex: 1,
    ),

    // ==============================
    // فئة: علوم — science
    // ==============================

    QuestionModel(
      id: 's1', categoryId: 'science', level: 1, points: 200,
      question: 'ما هو رمز الأكسجين في الجدول الدوري؟',
      options: ['Ox', 'O', 'Og', 'Os'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 's2', categoryId: 'science', level: 1, points: 200,
      question: 'كم تبلغ سرعة الضوء تقريباً؟',
      options: ['300 كم/ث', '3000 كم/ث', '300,000 كم/ث', '3,000,000 كم/ث'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 's3', categoryId: 'science', level: 1, points: 200,
      question: 'ما هي أصغر وحدة في الكائن الحي؟',
      options: ['الذرة', 'الخلية', 'الجزيء', 'البكتيريا'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 's4', categoryId: 'science', level: 2, points: 400,
      question: 'ما هو العنصر الأكثر وفرة في القشرة الأرضية؟',
      options: ['الحديد', 'الكربون', 'الأكسجين', 'السيليكون'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 's5', categoryId: 'science', level: 2, points: 400,
      question: 'كم عدد أسنان الإنسان البالغ؟',
      options: ['28', '30', '32', '34'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 's6', categoryId: 'science', level: 3, points: 600,
      question: 'ما هو الجهاز المسؤول عن ضخ الدم في الجسم؟',
      options: ['الرئة', 'الكبد', 'القلب', 'الكلية'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 's7', categoryId: 'science', level: 3, points: 600,
      question: 'ما هو أخف عنصر في الجدول الدوري؟',
      options: ['الهيليوم', 'الهيدروجين', 'الليثيوم', 'الكربون'],
      correctIndex: 1,
    ),

    // ==============================
    // فئة: تاريخ — history
    // ==============================

    QuestionModel(
      id: 'h1', categoryId: 'history', level: 1, points: 200,
      question: 'في أي سنة فتح المسلمون مكة المكرمة؟',
      options: ['٦٢٠ م', '٦٢٨ م', '٦٣٠ م', '٦٣٢ م'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'h2', categoryId: 'history', level: 1, points: 200,
      question: 'من هو أول رئيس للولايات المتحدة الأمريكية؟',
      options: ['أبراهام لينكولن', 'جورج واشنطن', 'توماس جيفرسون', 'بنجامين فرانكلين'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 'h3', categoryId: 'history', level: 1, points: 200,
      question: 'في أي سنة بدأت الحرب العالمية الثانية؟',
      options: ['1935', '1937', '1939', '1941'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'h4', categoryId: 'history', level: 2, points: 400,
      question: 'من بنى الأهرامات؟',
      options: ['الرومان', 'الإغريق', 'الفراعنة', 'الفينيقيون'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'h5', categoryId: 'history', level: 2, points: 400,
      question: 'ما هي عاصمة الخلافة العباسية؟',
      options: ['دمشق', 'القاهرة', 'بغداد', 'الكوفة'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'h6', categoryId: 'history', level: 3, points: 600,
      question: 'في أي عام سقطت الخلافة العثمانية؟',
      options: ['1918', '1920', '1922', '1924'],
      correctIndex: 3,
    ),
    QuestionModel(
      id: 'h7', categoryId: 'history', level: 3, points: 600,
      question: 'من اخترع الطباعة؟',
      options: ['نيوتن', 'غوتنبرغ', 'داVinci', 'أرخميدس'],
      correctIndex: 1,
    ),

    // ==============================
    // فئة: رياضة — sports
    // ==============================

    QuestionModel(
      id: 'sp1', categoryId: 'sports', level: 1, points: 200,
      question: 'كم عدد لاعبي كرة القدم في كل فريق؟',
      options: ['9', '10', '11', '12'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'sp2', categoryId: 'sports', level: 1, points: 200,
      question: 'في أي دولة نشأت رياضة كرة السلة؟',
      options: ['كندا', 'أمريكا', 'إنجلترا', 'فرنسا'],
      correctIndex: 0,
    ),
    QuestionModel(
      id: 'sp3', categoryId: 'sports', level: 1, points: 200,
      question: 'كم مرة فازت البرازيل بكأس العالم؟',
      options: ['3', '4', '5', '6'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'sp4', categoryId: 'sports', level: 2, points: 400,
      question: 'ما هو طول ملعب كرة القدم الرسمي؟',
      options: ['90-100 م', '100-110 م', '90-120 م', '100-130 م'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 'sp5', categoryId: 'sports', level: 2, points: 400,
      question: 'كم عدد حلقات علم الأولمبياد؟',
      options: ['4', '5', '6', '7'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 'sp6', categoryId: 'sports', level: 3, points: 600,
      question: 'من هو أكثر لاعب تسجيلاً للأهداف في تاريخ كرة القدم؟',
      options: ['رونالدو', 'ميسي', 'بيليه', 'مارادونا'],
      correctIndex: 0,
    ),
    QuestionModel(
      id: 'sp7', categoryId: 'sports', level: 3, points: 600,
      question: 'في أي مدينة أقيمت أول دورة أولمبية حديثة؟',
      options: ['باريس', 'لندن', 'أثينا', 'روما'],
      correctIndex: 2,
    ),

    // ==============================
    // فئة: تقنية — tech
    // ==============================

    QuestionModel(
      id: 't1', categoryId: 'tech', level: 1, points: 200,
      question: 'ما معنى اختصار WWW؟',
      options: ['World Wide Web', 'World Web Wide', 'Wide World Web', 'Web World Wide'],
      correctIndex: 0,
    ),
    QuestionModel(
      id: 't2', categoryId: 'tech', level: 1, points: 200,
      question: 'من أسس شركة Apple؟',
      options: ['بيل غيتس', 'ستيف جوبز', 'إيلون ماسك', 'مارك زوكربيرغ'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 't3', categoryId: 'tech', level: 1, points: 200,
      question: 'ما هو أشهر نظام تشغيل للهواتف الذكية؟',
      options: ['Windows', 'Linux', 'Android', 'macOS'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 't4', categoryId: 'tech', level: 2, points: 400,
      question: 'ما معنى اختصار CPU؟',
      options: ['Central Processing Unit', 'Computer Power Unit', 'Central Power Unit', 'Computer Processing Unit'],
      correctIndex: 0,
    ),
    QuestionModel(
      id: 't5', categoryId: 'tech', level: 2, points: 400,
      question: 'في أي سنة تأسست شركة Google؟',
      options: ['1996', '1998', '2000', '2002'],
      correctIndex: 1,
    ),
    QuestionModel(
      id: 't6', categoryId: 'tech', level: 3, points: 600,
      question: 'ما هي لغة البرمجة المستخدمة في تطوير هذه اللعبة؟',
      options: ['Python', 'JavaScript', 'Dart', 'Swift'],
      correctIndex: 2,
    ),
    QuestionModel(
      id: 't7', categoryId: 'tech', level: 3, points: 600,
      question: 'ما معنى اختصار AI؟',
      options: ['Automatic Internet', 'Artificial Intelligence', 'Advanced Interface', 'Applied Innovation'],
      correctIndex: 1,
    ),

  ];

  // ==============================
  // دالة تجيب أسئلة حسب الفئة والمستوى
  // ==============================
  static List<QuestionModel> getByLevelAndCategory(
      String categoryId, int level) {
    return questions
        .where((q) => q.categoryId == categoryId && q.level == level)
        .toList();
  }

  // ==============================
  // دالة تجيب أسئلة حسب المستوى فقط
  // تستخدم كـ fallback
  // ==============================
  static List<QuestionModel> getByLevel(int level) {
    return questions.where((q) => q.level == level).toList();
  }
}