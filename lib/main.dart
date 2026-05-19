// ==============================
// الملف الرئيسي للتطبيق
// اسم اللعبة: منو أذكى
// ==============================

import 'package:flutter/material.dart';

// ==============================
// نقطة البداية — أول شي يشتغل
// ==============================
void main() {
  runApp(const MnoAthkaApp());
}

// ==============================
// MnoAthkaApp
// الكلاس الرئيسي للتطبيق
// StatelessWidget = ما يتغير شكله
// ==============================
class MnoAthkaApp extends StatelessWidget {
  const MnoAthkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // اسم التطبيق
      title: 'منو أذكى',

      // إخفاء شريط debug الأحمر
      debugShowCheckedModeBanner: false,

      // ==============================
      // الثيم — ألوان اللعبة
      // ==============================
      theme: ThemeData(
        // اللون الأساسي للعبة
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // بنفسجي
        ),
        useMaterial3: true,
      ),

      // الشاشة الرئيسية
      home: const HomeScreen(),
    );
  }
}

// ==============================
// HomeScreen
// الشاشة الرئيسية للعبة
// StatelessWidget = ما تحتاج حالة
// ==============================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون خلفية الشاشة
      backgroundColor: const Color(0xFF1A1A2E),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ==============================
            // أيقونة اللعبة
            // ==============================
            const Icon(
              Icons.emoji_events, // أيقونة كأس
              size: 100,          // الحجم
              color: Color(0xFFFFD700), // لون ذهبي
            ),

            // مسافة بين الأيقونة والنص
            const SizedBox(height: 24),

            // ==============================
            // اسم اللعبة
            // ==============================
            const Text(
              'منو أذكى؟',
              style: TextStyle(
                fontSize: 42,                    // حجم الخط
                fontWeight: FontWeight.bold,     // سماكة الخط
                color: Colors.white,             // لون النص
              ),
            ),

            // مسافة
            const SizedBox(height: 12),

            // ==============================
            // وصف صغير
            // ==============================
            const Text(
              'اختبر معلوماتك وتحدى أصدقاءك',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54, // أبيض شفاف
              ),
            ),

            // مسافة كبيرة
            const SizedBox(height: 48),

            // ==============================
            // زر ابدأ اللعبة
            // ElevatedButton = زر مرفوع
            // ==============================
            ElevatedButton(
              // onPressed = شو يصير لما تضغط الزر
              onPressed: () {
                // لحين — رسالة مؤقتة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('قريباً — شاشة اللعبة!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF), // لون الزر
                foregroundColor: Colors.white,            // لون النص
                padding: const EdgeInsets.symmetric(
                  horizontal: 48, // مسافة أفقية
                  vertical: 16,   // مسافة عمودية
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // زوايا دائرية
                ),
              ),
              child: const Text(
                'ابدأ اللعبة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}