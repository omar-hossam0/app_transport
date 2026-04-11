import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import '../services/language_service.dart';
import 'package:provider/provider.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageService>().isArabic;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        title: Text(
          isArabic ? 'مركز المساعدة' : 'Help Center',
          style: roboto(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0.4,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HelpCard(
            title: isArabic ? 'المشاكل الشائعة' : 'Common Issues',
            items: [
              isArabic ? 'لا أستطيع تسجيل الدخول' : 'I cannot sign in',
              isArabic
                  ? 'لا تصلني رسالة التحقق'
                  : 'Verification email not received',
              isArabic ? 'لا تظهر الرحلات' : 'Trips are not loading',
            ],
          ),
          const SizedBox(height: 12),
          _HelpCard(
            title: isArabic ? 'الحجوزات' : 'Bookings',
            items: [
              isArabic
                  ? 'كيف يمكنني إلغاء الحجز؟'
                  : 'How do I cancel a booking?',
              isArabic ? 'كيف أراجع حجوزاتي؟' : 'Where can I find my bookings?',
            ],
          ),
          const SizedBox(height: 12),
          _HelpCard(
            title: isArabic ? 'الدفع' : 'Payments',
            items: [
              isArabic ? 'طرق الدفع المتاحة' : 'Available payment methods',
              isArabic ? 'مشكلة في الدفع' : 'Payment issues',
            ],
          ),
          const SizedBox(height: 12),
          _HelpCard(
            title: isArabic ? 'الأمان والحساب' : 'Account & Security',
            items: [
              isArabic ? 'تغيير كلمة المرور' : 'Change password',
              isArabic ? 'تحديث بيانات الملف الشخصي' : 'Update profile details',
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HelpCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: roboto(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...items.map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, size: 16, color: kBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: roboto(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
