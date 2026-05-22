// ==============================
// ملف بيانات الفئات
// اسم الملف: categories_data.dart
// المكان: lib/data/repositories/
//
// ٦ فئات تجريبية الآن
// بعدين نكملها ٤٠ فئة مع Supabase
// ==============================

import '../models/category_model.dart';

class CategoriesData {

  static const List<CategoryModel> categories = [

    CategoryModel(
      id: 'general',
      title: 'معلومات عامة',
      emoji: '🌍',
      description: 'أسئلة متنوعة من كل المجالات',
    ),

    CategoryModel(
      id: 'science',
      title: 'علوم',
      emoji: '🔬',
      description: 'فيزياء، كيمياء، أحياء',
    ),

    CategoryModel(
      id: 'history',
      title: 'تاريخ',
      emoji: '📜',
      description: 'أحداث وشخصيات تاريخية',
    ),

    CategoryModel(
      id: 'sports',
      title: 'رياضة',
      emoji: '⚽',
      description: 'كرة قدم وألعاب رياضية',
    ),

    CategoryModel(
      id: 'tech',
      title: 'تقنية',
      emoji: '💻',
      description: 'تكنولوجيا وذكاء اصطناعي',
    ),

    CategoryModel(
      id: 'quran',
      title: 'قرآن وإسلاميات',
      emoji: '📖',
      description: 'أسئلة دينية وقرآنية',
      isLocked: true, // مقفلة — تفتح لاحقاً
    ),

  ];
}