import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import '../services/language_service.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageService>().isArabic;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        title: Text(
          isArabic ? 'الشروط والاحكام' : 'Terms & Conditions',
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
            title: isArabic ? 'الاستخدام المقبول' : 'Acceptable Use',
            body: isArabic
                ? 'يجب استخدام التطبيق بطريقة قانونية ودون إساءة.'
                : 'Use the app lawfully and without misuse.',
          ),
          _Section(
            title: isArabic ? 'الحجوزات' : 'Bookings',
            body: isArabic
                ? 'الحجوزات تخضع لتوافر الخدمة وسياسات الإلغاء.'
                : 'Bookings depend on availability and cancellation policies.',
          ),
          _Section(
            title: isArabic ? 'المدفوعات' : 'Payments',
            body: isArabic
                ? 'يجب إتمام الدفع حسب الطريقة المختارة.'
                : 'Payments must be completed using the selected method.',
          ),
          _Section(
            title: isArabic ? 'المسؤولية' : 'Liability',
            body: isArabic
                ? 'نحن غير مسؤولين عن الأعطال الخارجة عن السيطرة.'
                : 'We are not liable for issues beyond our control.',
          ),
          _Section(
            title: isArabic ? 'التعديلات' : 'Changes',
            body: isArabic
                ? 'قد نقوم بتحديث الشروط عند الحاجة.'
                : 'We may update terms when needed.',
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
