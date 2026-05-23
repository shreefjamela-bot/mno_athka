// ==============================
// شاشة تسجيل الدخول
// اسم الملف: auth_screen.dart
// المكان: lib/features/auth/
//
// تسجيل دخول وإنشاء حساب بالإيميل
// ==============================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  // ==============================
  // المتغيرات
  // ==============================

  // كونترولر الإيميل — يقرأ النص من الخانة
  final _emailController = TextEditingController();

  // كونترولر كلمة السر
  final _passwordController = TextEditingController();

  // هل في تسجيل دخول أو إنشاء حساب
  bool _isLogin = true;

  // هل يحمّل
  bool _isLoading = false;

  // إخفاء كلمة السر
  bool _obscurePassword = true;

  // اتصال Supabase
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==============================
  // دالة تسجيل الدخول
  // ==============================
  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // نجح تسجيل الدخول — ارجع للرئيسية
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول بنجاح ✅'),
            backgroundColor: AppColors.correct,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في تسجيل الدخول — تحقق من البيانات'),
            backgroundColor: AppColors.wrong,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ==============================
  // دالة إنشاء حساب جديد
  // ==============================
  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح ✅'),
            backgroundColor: AppColors.correct,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في إنشاء الحساب'),
            backgroundColor: AppColors.wrong,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // أيقونة
            const Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.primary,
            ),

            const SizedBox(height: AppSizes.spaceXL),

            // ==============================
            // خانة الإيميل
            // ==============================
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'الإيميل',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.primary),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // ==============================
            // خانة كلمة السر
            // ==============================
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'كلمة السر',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.lock_outlined,
                    color: AppColors.primary),
                // زر إظهار/إخفاء كلمة السر
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceXL),

            // ==============================
            // زر تسجيل الدخول / إنشاء حساب
            // ==============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_isLogin ? _signIn : _signUp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMD),

            // ==============================
            // تبديل بين تسجيل الدخول وإنشاء حساب
            // ==============================
            TextButton(
              onPressed: () {
                setState(() => _isLogin = !_isLogin);
              },
              child: Text(
                _isLogin
                    ? 'ما عندك حساب؟ أنشئ حساب جديد'
                    : 'عندك حساب؟ سجّل دخول',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: AppSizes.fontMD,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}