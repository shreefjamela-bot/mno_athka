// ==============================
// شاشة أضف سؤالك الخاص
// اسم الملف: user_questions_screen.dart
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';

class UserQuestionsScreen extends StatefulWidget {
  const UserQuestionsScreen({super.key});

  @override
  State<UserQuestionsScreen> createState() => _UserQuestionsScreenState();
}

class _UserQuestionsScreenState extends State<UserQuestionsScreen> {
  final _emailController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  String _selectedCategory = 'معلومات عامة';
  int _selectedLevel = 1;
  bool _isLoading = false;
  bool _submitted = false;

  final List<String> _categories = [
    'معلومات عامة', 'تاريخ', 'رياضة', 'علوم', 'دين',
    'ترفيه', 'جغرافيا', 'تقنية', 'فن وثقافة', 'رياضيات',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_questionController.text.trim().isEmpty ||
        _answerController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('user_questions').insert({
        'user_email': _emailController.text.trim().isEmpty
            ? 'anonymous'
            : _emailController.text.trim(),
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
        'category': _selectedCategory,
        'level': _selectedLevel,
        'status': 'pending',
      });

      setState(() {
        _isLoading = false;
        _submitted = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ، حاول مرة أخرى'),
            backgroundColor: AppColors.wrong,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'أضف سؤالك الخاص',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.correct.withOpacity(0.15),
                border: Border.all(color: AppColors.correct, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.correct.withOpacity(0.3),
                      blurRadius: 20),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.correct, size: 50),
            ),
            const SizedBox(height: 24),
            const Text(
              '🎉 سؤالك وصلنا!',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'سيتم مراجعة سؤالك وإضافته للعبة\nستحصل على نقاط عند قبوله',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  setState(() {
                    _submitted = false;
                    _questionController.clear();
                    _answerController.clear();
                    _emailController.clear();
                  });
                },
                child: const Text(
                  'أضف سؤالاً آخر',
                  style: TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ارجع للرئيسية',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // الهيدر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorderGold),
              boxShadow: [
                BoxShadow(color: AppColors.glowGold, blurRadius: 12),
              ],
            ),
            child: const Column(
              children: [
                Text('✍️', style: TextStyle(fontSize: 40)),
                SizedBox(height: 12),
                Text(
                  'شارك معلوماتك',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'أضف سؤالاً وسيظهر في اللعبة بعد المراجعة\nستحصل على نقاط مقابل كل سؤال مقبول',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // البريد الإلكتروني
          _buildLabel('بريدك الإلكتروني (اختياري)'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('example@email.com'),
          ),

          const SizedBox(height: 20),

          // الفئة
          _buildLabel('الفئة *'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primary),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val!),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // المستوى
          _buildLabel('المستوى *'),
          const SizedBox(height: 8),
          Row(
            children: [1, 2, 3].map((level) {
              final labels = {1: '200 — سهل', 2: '400 — متوسط', 3: '600 — صعب'};
              final colors = {
                1: AppColors.correct,
                2: AppColors.gold,
                3: AppColors.wrong,
              };
              final isSelected = _selectedLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedLevel = level),
                  child: Container(
                    margin: EdgeInsets.only(
                        left: level < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors[level]!.withOpacity(0.2)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colors[level]!
                            : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      labels[level]!,
                      style: TextStyle(
                        color: isSelected
                            ? colors[level]!
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // السؤال
          _buildLabel('السؤال *'),
          const SizedBox(height: 8),
          TextField(
            controller: _questionController,
            textAlign: TextAlign.right,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('اكتب سؤالك هنا...'),
          ),

          const SizedBox(height: 20),

          // الإجابة
          _buildLabel('الإجابة الصحيحة *'),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('اكتب الإجابة الصحيحة...'),
          ),

          const SizedBox(height: 32),

          // زر الإرسال
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'أرسل سؤالك ✍️',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: AppColors.textHint, fontSize: 13),
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}