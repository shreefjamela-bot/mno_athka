// ==============================
// نموذج الفئة (القالب)
// اسم الملف: category_model.dart
// المكان: lib/data/models/
//
// كل فئة عندها: اسم، أيقونة، لون، أسئلة
// ==============================

class CategoryModel {

  // رقم تعريفي فريد
  final String id;

  // اسم الفئة
  final String title;

  // أيقونة الفئة
  final String emoji;

  // وصف قصير
  final String description;

  // هل مفتوحة أو مقفلة
  final bool isLocked;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    this.isLocked = false,
  });
}