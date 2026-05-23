// ==============================
// ملف التخزين المحلي
// اسم الملف: local_storage.dart
// المكان: lib/data/repositories/
//
// يحفظ بيانات اللاعب على الجهاز
// حتى لو أغلق التطبيق تبقى محفوظة
// ==============================

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  // ==============================
  // مفاتيح التخزين — ثابتة
  // نستخدمها للحفظ والقراءة
  // ==============================
  static const String _keyHighScore = 'high_score';
  static const String _keyTotalGames = 'total_games';
  static const String _keyCorrectAnswers = 'correct_answers';

  // ==============================
  // حفظ أعلى نقاط
  // ==============================
  static Future<void> saveHighScore(int score) async {
    // نجيب النسخة الحالية
    final prefs = await SharedPreferences.getInstance();

    // نجيب الرقم المحفوظ — افتراضي ٠
    final currentHigh = prefs.getInt(_keyHighScore) ?? 0;

    // نحفظ فقط إذا النقاط الجديدة أعلى
    if (score > currentHigh) {
      await prefs.setInt(_keyHighScore, score);
    }
  }

  // ==============================
  // جيب أعلى نقاط
  // ==============================
  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  // ==============================
  // زد عدد الجولات
  // ==============================
  static Future<void> incrementTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyTotalGames) ?? 0;
    await prefs.setInt(_keyTotalGames, current + 1);
  }

  // ==============================
  // جيب عدد الجولات
  // ==============================
  static Future<int> getTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalGames) ?? 0;
  }

  // ==============================
  // زد عدد الإجابات الصحيحة
  // ==============================
  static Future<void> addCorrectAnswers(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCorrectAnswers) ?? 0;
    await prefs.setInt(_keyCorrectAnswers, current + count);
  }

  // ==============================
  // جيب عدد الإجابات الصحيحة
  // ==============================
  static Future<int> getCorrectAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCorrectAnswers) ?? 0;
  }
}