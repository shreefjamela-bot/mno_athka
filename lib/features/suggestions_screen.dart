// ==============================
// شاشة اقتراحات الزوار
// اسم الملف: suggestions_screen.dart
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final _nameController = TextEditingController();
  final _suggestionController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_suggestionController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('suggestions').insert({
        'name': _nameController.text.trim().isEmpty
            ? 'زائر مجهول'
            : _nameController.text.trim(),
        'suggestion': _suggestionController.text.trim(),
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
          'اقتراحاتك تهمنا',
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

  // ── شاشة النجاح ─────────────────────────────────
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
              'شكراً لك! 🙏',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'اقتراحك وصلنا وسنأخذه بعين الاعتبار\nرأيك يساعدنا على تطوير اللعبة',
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ارجع للرئيسية',
                  style: TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── الفورم ──────────────────────────────────────
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
            child: Column(
              children: [
                const Text('💬', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text(
                  'شاركنا رأيك',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اقتراحاتك تساعدنا على تطوير اللعبة\nوإضافة ميزات جديدة تناسبكم',
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

          // اسمك (اختياري)
          _buildLabel('اسمك (اختياري)'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('مثال: أحمد أو زائر'),
          ),

          const SizedBox(height: 20),

          // الاقتراح
          _buildLabel('اقتراحك *'),
          const SizedBox(height: 8),
          TextField(
            controller: _suggestionController,
            textAlign: TextAlign.right,
            maxLines: 5,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
                'اكتب اقتراحك هنا... مثل: أضيفوا فئة رياضة، أو غيّروا شكل اللوحة...'),
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
                shadowColor: AppColors.glowGold,
                elevation: 4,
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
                'أرسل اقتراحك 📨',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ملاحظة
          const Center(
            child: Text(
              '🔒 اقتراحك محفوظ لدينا ولن يُشارك مع أحد',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),

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
      hintStyle: const TextStyle(
          color: AppColors.textHint, fontSize: 13),
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