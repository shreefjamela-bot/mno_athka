// ==============================
// نموذج السؤال
// اسم الملف: question_model.dart
// المكان: lib/data/models/
// ==============================

class QuestionModel {

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int level;
  final int points;
  final String categoryId;
  final String? imageUrl;
  final String? videoUrl;
  final String? answerImageUrl;
  final int timeLimitSeconds;
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
    this.answerImageUrl,
    this.timeLimitSeconds = 120,
    this.answer,
  });

  bool get isOpenQuestion => options.isEmpty;

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctIndex;
  }

  static int getPointsByLevel(int level) {
    switch (level) {
      case 1: return 200;
      case 2: return 400;
      case 3: return 600;
      default: return 200;
    }
  }
}