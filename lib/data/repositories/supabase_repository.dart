// ==============================
// ملف Supabase Repository
// اسم الملف: supabase_repository.dart
// المكان: lib/data/repositories/
// ==============================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';

class SupabaseRepository {

  static final _client = Supabase.instance.client;

  // ==============================
  // جيب كل الفئات من Supabase
  // ==============================
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('id');

      return response.map((row) => CategoryModel(
        id: row['id'],
        title: row['title'],
        emoji: row['emoji'],
        description: row['description'] ?? '',
        isLocked: row['is_locked'] ?? false,
        // نجيب image_url — يقدر يكون null
        imageUrl: row['image_url'],
      )).toList();

    } catch (e) {
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
      final response = await _client
          .from('questions')
          .select()
          .eq('category_id', categoryId)
          .eq('level', level)
          .order('id');

      return response.map((row) => QuestionModel(
        id: row['id'],
        categoryId: row['category_id'],
        level: row['level'],
        points: row['points'],
        question: row['question'],
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