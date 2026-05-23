// ==============================
// ملف Supabase Repository
// اسم الملف: supabase_repository.dart
// المكان: lib/data/repositories/
//
// يجيب البيانات من Supabase
// الفئات والأسئلة
// ==============================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';

class SupabaseRepository {

  // الاتصال بـ Supabase
  static final _client = Supabase.instance.client;

  // ==============================
  // جيب كل الفئات من Supabase
  // ==============================
  static Future<List<CategoryModel>> getCategories() async {
    try {
      // نجيب البيانات من جدول categories
      final response = await _client
          .from('categories')
          .select()
          .order('id');

      // نحول كل صف لـ CategoryModel
      return response.map((row) => CategoryModel(
        id: row['id'],
        title: row['title'],
        emoji: row['emoji'],
        description: row['description'] ?? '',
        isLocked: row['is_locked'] ?? false,
      )).toList();

    } catch (e) {
      // لو في خطأ — نرجع قائمة فاضية
      return [];
    }
  }

  // ==============================
  // جيب أسئلة حسب الفئة والمستوى
  // ==============================
  static Future<List<QuestionModel>> getQuestions({
    required String categoryId,
    required int level,
  }) async {
    try {
      // نجيب الأسئلة من جدول questions
      final response = await _client
          .from('questions')
          .select()
          .eq('category_id', categoryId)
          .eq('level', level)
          .order('id');

      // نحول كل صف لـ QuestionModel
      return response.map((row) => QuestionModel(
        id: row['id'],
        categoryId: row['category_id'],
        level: row['level'],
        points: row['points'],
        question: row['question'],
        // options محفوظة كـ JSON — نحولها لقائمة
        options: List<String>.from(row['options']),
        correctIndex: row['correct_index'],
        imageUrl: row['image_url'],
        videoUrl: row['video_url'],
        timeLimitSeconds: row['time_limit_seconds'] ?? 120,
      )).toList();

    } catch (e) {
      return [];
    }
  }
}