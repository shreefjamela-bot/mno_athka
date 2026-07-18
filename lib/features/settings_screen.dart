// ==============================
// شاشة الإعدادات — Luxury Theme
// ==============================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _gold = Color(0xFFC49830);
const _goldLight = Color(0xFFF0D060);
const _bg = Color(0xFF080808);
const _cardBg = Color(0xFF0E0E0E);
const _goldText = Color(0xFF5A4820);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // يفتح شاشة نصية داخل التطبيق بدل المتصفح الخارجي
  void _openLegalPage(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LegalPage(title: title, content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ===== هيدر =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _gold.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.arrow_back_ios_rounded, color: _gold.withOpacity(0.7), size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_goldLight, _gold],
                    ).createShader(bounds),
                    child: const Text('الإعدادات',
                        style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ===== قسم قانوني =====
                    _sectionTitle('⚖️ قانوني'),
                    const SizedBox(height: 8),

                    _settingsItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'سياسة الخصوصية',
                      subtitle: 'كيف نحمي بياناتك',
                      onTap: () => _openLegalPage(context, 'سياسة الخصوصية', _privacyText),
                    ),
                    const SizedBox(height: 8),
                    _settingsItem(
                      icon: Icons.description_outlined,
                      title: 'شروط الاستخدام',
                      subtitle: 'قواعد استخدام التطبيق',
                      onTap: () => _openLegalPage(context, 'شروط الاستخدام', _termsText),
                    ),

                    const SizedBox(height: 24),

                    // ===== قسم التواصل =====
                    _sectionTitle('💬 تواصل معنا'),
                    const SizedBox(height: 8),

                    _settingsItem(
                      icon: Icons.email_outlined,
                      title: 'راسلنا',
                      subtitle: 'mno.athka@gmail.com',
                      onTap: () => _launchUrl('mailto:mno.athka@gmail.com'),
                    ),
                    const SizedBox(height: 8),
                    _settingsItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'اقتراحاتك تهمنا',
                      subtitle: 'شاركنا أفكارك لتطوير التطبيق',
                      onTap: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 24),

                    // ===== قسم التقييم =====
                    _sectionTitle('⭐ قيّم التطبيق'),
                    const SizedBox(height: 8),

                    _settingsItem(
                      icon: Icons.star_outline_rounded,
                      title: 'قيّم منو أذكى؟',
                      subtitle: 'رأيك يساعدنا على التحسين',
                      onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.mnoathka.app'),
                      trailing: const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 14)),
                    ),

                    const SizedBox(height: 24),

                    // ===== معلومات التطبيق =====
                    _sectionTitle('ℹ️ عن التطبيق'),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _gold.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          // لوغو صغير
                          const Text('🧠', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_goldLight, _gold],
                            ).createShader(bounds),
                            child: const Text('منو أذكى؟',
                                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(height: 4),
                          Text('مسابقات وتحديات ذكية',
                              style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 12)),
                          const SizedBox(height: 12),
                          Container(height: 0.5, color: _gold.withOpacity(0.2)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الإصدار', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 13)),
                              Text('1.0.0', style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('المطوّر', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 13)),
                              Text('فريق منو أذكى', style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('سنة الإصدار', style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.5), fontSize: 13)),
                              Text('2026', style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Center(
                      child: Text('© 2026 منو أذكى؟ — جميع الحقوق محفوظة',
                          style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.3), fontSize: 11),
                          textAlign: TextAlign.center),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: TextStyle(fontFamily: 'Tajawal', color: _gold.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1));
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _gold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: Icon(icon, color: _gold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontFamily: 'Tajawal', color: _goldLight, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(fontFamily: 'Tajawal', color: _goldText.withOpacity(0.6), fontSize: 11)),
                ],
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios_rounded, color: _goldText.withOpacity(0.3), size: 14),
          ],
        ),
      ),
    );
  }
}

// ==============================
// شاشة عرض النصوص القانونية داخل التطبيق
// ==============================
class _LegalPage extends StatelessWidget {
  final String title;
  final String content;

  const _LegalPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ===== هيدر =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _gold.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.arrow_back_ios_rounded, color: _gold.withOpacity(0.7), size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_goldLight, _gold],
                      ).createShader(bounds),
                      child: Text(title,
                          style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withOpacity(0.2)),
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: _goldLight.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.9,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ==============================
// النصوص القانونية (عدّلها كما تريد)
// ==============================
const String _privacyText = '''
مرحباً بك في تطبيق "منو أذكى؟". نحن نحترم خصوصيتك ونلتزم بحمايتها.

١. البيانات التي نجمعها
قد نجمع معلومات محدودة مثل البريد الإلكتروني عند التواصل معنا، وبيانات الاستخدام العامة لتحسين التطبيق. لا نبيع بياناتك لأي طرف ثالث.

٢. كيف نستخدم بياناتك
تُستخدم البيانات فقط لتشغيل التطبيق وتحسين تجربتك وتقديم الدعم عند الحاجة.

٣. أمان البيانات
نتخذ إجراءات معقولة لحماية بياناتك، لكن لا يمكن ضمان الأمان الكامل عبر الإنترنت.

٤. حقوقك
يحق لك طلب حذف بياناتك أو الاستفسار عنها في أي وقت عبر مراسلتنا على البريد الإلكتروني.

٥. التعديلات
قد نحدّث سياسة الخصوصية من وقت لآخر، وسيظهر أي تعديل داخل التطبيق.

للتواصل: mno.athka@gmail.com
''';

const String _termsText = '''
باستخدامك لتطبيق "منو أذكى؟" فإنك توافق على الشروط التالية:

١. استخدام التطبيق
التطبيق مخصص للترفيه والمسابقات. يُمنع استخدامه لأي غرض غير قانوني أو مسيء.

٢. المحتوى
جميع الأسئلة والتحديات والمحتوى داخل التطبيق ملك لفريق "منو أذكى؟"، ولا يجوز نسخها أو إعادة نشرها دون إذن.

٣. حساب المستخدم
أنت مسؤول عن أي نشاط يتم عبر جهازك أو حسابك داخل التطبيق.

٤. المحتوى المُقترح
عند إرسال اقتراحات أو أسئلة، فإنك تمنحنا الحق في استخدامها وتطويرها داخل التطبيق.

٥. إخلاء المسؤولية
نقدّم التطبيق "كما هو" دون أي ضمانات. لا نتحمل مسؤولية أي أضرار ناتجة عن الاستخدام.

٦. التعديلات
نحتفظ بحق تعديل هذه الشروط في أي وقت، وسيظهر أي تغيير داخل التطبيق.

للتواصل: mno.athka@gmail.com
''';