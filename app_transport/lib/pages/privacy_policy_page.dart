import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import '../services/language_service.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageService>().isArabic;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        title: Text(
          isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
          style: roboto(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0.4,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _Section(
            title: isArabic ? 'جمع البيانات' : 'Data Collection',
            body: isArabic
                ? 'نجمع البيانات اللازمة لتقديم خدمات الحجز وإدارة الحساب.'
                : 'We collect data needed to provide bookings and manage accounts.',
          ),
          _Section(
            title: isArabic ? 'استخدام البيانات' : 'Data Usage',
            body: isArabic
                ? 'تستخدم البيانات لتحسين التجربة وتقديم دعم العملاء.'
                : 'Data is used to improve the experience and support customers.',
          ),
          _Section(
            title: isArabic ? 'حماية البيانات' : 'Data Protection',
            body: isArabic
                ? 'نطبق إجراءات أمان لحماية بياناتك من الوصول غير المصرح.'
                : 'We apply security measures to protect your data from unauthorized access.',
          ),
          _Section(
            title: isArabic ? 'مشاركة البيانات' : 'Data Sharing',
            body: isArabic
                ? 'لا نشارك بياناتك إلا إذا لزم الأمر لتقديم الخدمة.'
                : 'We do not share your data unless required to deliver the service.',
          ),
          _Section(
            title: isArabic ? 'الاتصال بنا' : 'Contact Us',
            body: isArabic
                ? 'لأي استفسار حول الخصوصية تواصل معنا عبر الدعم.'
                : 'For privacy inquiries, please contact support.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: roboto(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: roboto(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
