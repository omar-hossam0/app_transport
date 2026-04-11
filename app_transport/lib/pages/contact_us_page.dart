import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_widgets.dart';
import '../services/language_service.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageService>().isArabic;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        title: Text(
          isArabic ? 'تواصل معنا' : 'Contact Us',
          style: roboto(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0.4,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _InfoTile(
            icon: Icons.mail_outline,
            title: isArabic ? 'البريد الإلكتروني' : 'Email',
            value: 'support@apptransport.com',
            onCopy: () => _copy(context, 'support@apptransport.com', isArabic),
            onTap: () => _launchEmail(context, isArabic),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.access_time,
            title: isArabic ? 'ساعات العمل' : 'Working Hours',
            value: isArabic ? 'يوميا 9 ص - 6 م' : 'Daily 9 AM - 6 PM',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: isArabic ? 'العنوان' : 'Address',
            value: isArabic ? 'القاهرة، مصر' : 'Cairo, Egypt',
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: isArabic ? 'ارسال بريد للدعم' : 'Email Support',
            icon: Icons.send_rounded,
            onTap: () => _launchEmail(context, isArabic),
          ),
          const SizedBox(height: 12),
          Container(
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
                Text(
                  isArabic ? 'ملاحظة' : 'Note',
                  style: roboto(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  isArabic
                      ? 'سيرد فريق الدعم خلال 24 ساعة.'
                      : 'Our support team will respond within 24 hours.',
                  style: roboto(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value, bool isArabic) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم نسخ البريد' : 'Email copied',
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kBlue,
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, bool isArabic) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@apptransport.com',
      queryParameters: {
        'subject': 'Support Request',
        'body': isArabic
            ? 'مرحبا، لدي استفسار بخصوص...'
            : 'Hello, I need help with...',
      },
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'تعذر فتح تطبيق البريد' : 'Unable to open email app',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onCopy;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onCopy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: roboto(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: roboto(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (onCopy != null)
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: kBlue,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kBlue, kLightBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kBlue.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: roboto(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
