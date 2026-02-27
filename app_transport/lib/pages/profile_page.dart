import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'auth_widgets.dart';

// ── Card brand SVG logos ────────────────────────────────────────────────────
const _kVisaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 750 471">
  <rect width="750" height="471" rx="40" fill="#1a1f71"/>
  <path d="M300 189.2l-48.6 92.2H230l-23.9-73.6c-1.4-5.6-2.7-7.6-7-10-7.1-3.9-18.7-7.5-29-9.7l.7-3.4h49.7c6.3 0 12 4.2 13.5 11.5l12.3 65.5 30.5-77H300zm108.5 62c.1-29.9-41.4-31.6-41.1-44.9.1-4.1 4-8.4 12.5-9.5 4.2-.6 15.8-.9 28.9 5.1l5.2-24.1c-7-2.5-16-5-27.2-5-28.7 0-48.9 15.3-49.1 37.1-.2 16.1 14.4 25.2 25.3 30.5 11.3 5.5 15.1 9.1 15.1 14 0 7.5-9 10.9-17.4 11-14.6.3-23-3.9-29.7-6.9l-5.2 24.5c6.7 3.1 19.2 5.8 32.2 6 30.4 0 50.2-15 50.3-38.8V251.2zm75.7 55.2h22.5L478.5 189.2h-20.8c-5.5 0-10.1 3.2-12.1 8l-42.6 95.2h29.9l5.9-16.4H478l3.2 16.4zm-41.7-39l14.8-40.7 8.5 40.7h-23.3zm-133.2-94.2l-23.5 95.2H258l23.5-95.2h27.8z" fill="#fff"/>
</svg>
''';

const _kMastercardSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 152.4 108">
  <rect width="152.4" height="108" rx="10" fill="#252525"/>
  <circle cx="60.2" cy="54" r="33" fill="#eb001b"/>
  <circle cx="92.2" cy="54" r="33" fill="#f79e1b"/>
  <path d="M76.2 26.3a33 33 0 0 1 0 55.4 33 33 0 0 1 0-55.4z" fill="#ff5f00"/>
</svg>
''';

// ─────────────────────────────────────────────────────────────────────────────
//  ProfilePage
// ─────────────────────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  final VoidCallback? onLogout;
  const ProfilePage({super.key, this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── User data ──────────────────────────────────────────────────────────────
  String _name = 'Omar Hossam';
  String _email = 'omar.hossam@email.com';
  String _phone = '+20 101 234 5678';
  String _selectedLang = 'English';

  // ── Payment cards ──────────────────────────────────────────────────────────
  final List<Map<String, String>> _cards = [
    {'type': 'Visa', 'last4': '4242', 'expiry': '12/27', 'default': 'true'},
    {
      'type': 'Mastercard',
      'last4': '8812',
      'expiry': '08/26',
      'default': 'false',
    },
  ];

  // ── Preferences ───────────────────────────────────────────────────────────
  bool _notifyTrips = true;
  bool _notifyOffers = false;
  bool _notifyReminder = true;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F4F8),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header bar ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Profile',
                        style: roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    _iconBtn(
                      Icons.settings_outlined,
                      onTap: () => _showSettingsSnack(),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  children: [
                    // ── 1. User info card ───────────────────────────────────
                    _UserInfoCard(
                      name: _name,
                      email: _email,
                      phone: _phone,
                      onEdit: () => _showEditProfile(),
                    ),

                    const SizedBox(height: 18),

                    // ── 2. Account Settings ─────────────────────────────────
                    _SectionBlock(
                      icon: Icons.manage_accounts_rounded,
                      title: 'Account Settings',
                      children: [
                        _SectionTile(
                          icon: Icons.lock_outline_rounded,
                          label: 'Change Password',
                          onTap: () => _showChangePassword(),
                        ),
                        _SectionTile(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Switch Account',
                          onTap: () => _showSwitchAccount(),
                        ),
                        _SectionTile(
                          icon: Icons.logout_rounded,
                          label: 'Log Out',
                          labelColor: const Color(0xFFE02850),
                          iconColor: const Color(0xFFE02850),
                          onTap: () => _confirmLogout(),
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── 3. Language ─────────────────────────────────────────
                    _SectionBlock(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: _LanguageSelector(
                            selected: _selectedLang,
                            onChanged: (v) {
                              setState(() => _selectedLang = v);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Language set to $v'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: kBlue,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── 4. Payment Methods ──────────────────────────────────
                    _SectionBlock(
                      icon: Icons.credit_card_rounded,
                      title: 'Payment Methods',
                      trailing: _smallBtn(
                        'Add Card',
                        Icons.add,
                        onTap: () => _showAddCard(),
                      ),
                      children: [
                        ..._cards.asMap().entries.map(
                          (e) => _PaymentCardTile(
                            card: e.value,
                            isDefault: e.value['default'] == 'true',
                            onSetDefault: () => setState(() {
                              for (var c in _cards) {
                                c['default'] = 'false';
                              }
                              _cards[e.key]['default'] = 'true';
                            }),
                            onRemove: () =>
                                setState(() => _cards.removeAt(e.key)),
                            showDivider: e.key < _cards.length - 1,
                          ),
                        ),
                        if (_cards.isEmpty)
                          _emptyRow(
                            'No saved cards yet',
                            Icons.credit_card_off_rounded,
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── 5. Preferences ──────────────────────────────────────
                    _SectionBlock(
                      icon: Icons.tune_rounded,
                      title: 'Preferences',
                      children: [
                        _ToggleTile(
                          icon: Icons.flight_takeoff_rounded,
                          label: 'Trip Notifications',
                          value: _notifyTrips,
                          onChanged: (v) => setState(() => _notifyTrips = v),
                        ),
                        _ToggleTile(
                          icon: Icons.local_offer_rounded,
                          label: 'Deals & Discounts',
                          value: _notifyOffers,
                          onChanged: (v) => setState(() => _notifyOffers = v),
                        ),
                        _ToggleTile(
                          icon: Icons.alarm_rounded,
                          label: 'Trip Reminder',
                          value: _notifyReminder,
                          onChanged: (v) => setState(() => _notifyReminder = v),
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── 6. Support ──────────────────────────────────────────
                    _SectionBlock(
                      icon: Icons.support_agent_rounded,
                      title: 'Support',
                      children: [
                        _SectionTile(
                          icon: Icons.help_outline_rounded,
                          label: 'Help Center',
                          onTap: () => _snack('Help Center coming soon'),
                        ),
                        _SectionTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Contact Us',
                          sub: 'support@apptransport.com',
                          onTap: () => _snack('Opening mail...'),
                        ),
                        _SectionTile(
                          icon: Icons.quiz_outlined,
                          label: 'FAQs',
                          onTap: () => _snack('FAQs coming soon'),
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── 7. Legal ────────────────────────────────────────────
                    _SectionBlock(
                      icon: Icons.gavel_rounded,
                      title: 'Legal',
                      children: [
                        _SectionTile(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Policy',
                          onTap: () => _snack('Opening Privacy Policy...'),
                        ),
                        _SectionTile(
                          icon: Icons.description_outlined,
                          label: 'Terms & Conditions',
                          onTap: () => _snack('Opening Terms...'),
                          showDivider: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── 8. Logout button ────────────────────────────────────
                    _LogoutButton(onTap: () => _confirmLogout()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: kBlue),
        ),
      );

  Widget _smallBtn(
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: roboto(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyRow(String msg, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 18),
        const SizedBox(width: 8),
        Text(msg, style: roboto(color: Colors.grey.shade400, fontSize: 13)),
      ],
    ),
  );

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: kBlue,
    ),
  );

  void _showSettingsSnack() => _snack('Settings page coming soon');

  // ── Edit Profile ───────────────────────────────────────────────────────────
  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final phoneCtrl = TextEditingController(text: _phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(
        nameCtrl: nameCtrl,
        phoneCtrl: phoneCtrl,
        onSave: (name, phone) {
          setState(() {
            _name = name;
            _phone = phone;
          });
          Navigator.pop(ctx);
          _snack('Profile updated successfully');
        },
      ),
    );
  }

  // ── Change Password ────────────────────────────────────────────────────────
  void _showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ChangePasswordSheet(),
    );
  }

  // ── Switch Account ─────────────────────────────────────────────────────────
  void _showSwitchAccount() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConfirmSheet(
        icon: Icons.swap_horiz_rounded,
        iconColor: kBlue,
        title: 'Switch Account',
        body: 'You will be logged out of your current account. Continue?',
        confirmLabel: 'Switch',
        confirmColor: kBlue,
        onConfirm: () {
          Navigator.pop(ctx);
          if (widget.onLogout != null) widget.onLogout!();
        },
      ),
    );
  }

  // ── Logout confirm ─────────────────────────────────────────────────────────
  void _confirmLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConfirmSheet(
        icon: Icons.logout_rounded,
        iconColor: const Color(0xFFE02850),
        title: 'Log Out',
        body: 'Are you sure you want to log out of App Transport?',
        confirmLabel: 'Log Out',
        confirmColor: const Color(0xFFE02850),
        onConfirm: () {
          Navigator.pop(ctx);
          if (widget.onLogout != null) widget.onLogout!();
        },
      ),
    );
  }

  // ── Add Card ───────────────────────────────────────────────────────────────
  void _showAddCard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCardSheet(
        onSave: (card) {
          setState(() => _cards.add(card));
          Navigator.pop(ctx);
          _snack('Card added successfully');
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  User Info Card
// ═════════════════════════════════════════════════════════════════════════════
class _UserInfoCard extends StatelessWidget {
  final String name, email, phone;
  final VoidCallback onEdit;
  const _UserInfoCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [kBlue, kLightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kBlue.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: roboto(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: roboto(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(phone, style: roboto(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          // Info chips row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.flight_rounded,
                label: '12 Trips',
                color: kBlue,
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.star_rounded,
                label: '4.8 Rating',
                color: const Color(0xFFFFC107),
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.calendar_month_rounded,
                label: 'Since 2024',
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Edit Profile button
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kBlue, kLightBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: roboto(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Section Block
// ═════════════════════════════════════════════════════════════════════════════
class _SectionBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  const _SectionBlock({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: kBlue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE8F4F8)),
          ...children,
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Section Tile
// ═════════════════════════════════════════════════════════════════════════════
class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool showDivider;
  const _SectionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.sub,
    this.labelColor,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? kBlue).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor ?? kBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: labelColor ?? const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (sub != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          sub!,
                          style: roboto(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: const Color(0xFFF0F6FB)),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Toggle Tile
// ═════════════════════════════════════════════════════════════════════════════
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: kBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: kBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: const Color(0xFFF0F6FB)),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Language Selector
// ═════════════════════════════════════════════════════════════════════════════
class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _LanguageSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const langs = [('English', '🇬🇧'), ('العربية', '🇪🇬')];
    return Row(
      children: langs.map((l) {
        final active = selected == l.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(l.$1),
            child: Container(
              margin: EdgeInsets.only(right: l == langs.first ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? kBlue : const Color(0xFFE8F4F8),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: active ? kBlue : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(l.$2, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    l.$1,
                    style: roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Payment Card Tile
// ═════════════════════════════════════════════════════════════════════════════
class _PaymentCardTile extends StatelessWidget {
  final Map<String, String> card;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;
  final bool showDivider;
  const _PaymentCardTile({
    required this.card,
    required this.isDefault,
    required this.onSetDefault,
    required this.onRemove,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isVisa = card['type'] == 'Visa';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Card logo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 36,
                  child: SvgPicture.string(
                    isVisa ? _kVisaSvg : _kMastercardSvg,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '•••• •••• •••• ${card['last4']}',
                          style: roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: kBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Default',
                              style: roboto(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: kBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expires ${card['expiry']}',
                      style: roboto(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (v) {
                  if (v == 'default') onSetDefault();
                  if (v == 'remove') onRemove();
                },
                itemBuilder: (_) => [
                  if (!isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: kBlue,
                          ),
                          const SizedBox(width: 8),
                          Text('Set as Default', style: roboto(fontSize: 13)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFE02850),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remove',
                          style: roboto(
                            fontSize: 13,
                            color: const Color(0xFFE02850),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: const Color(0xFFF0F6FB)),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Logout Button
// ═════════════════════════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFE02850).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE02850).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE02850),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Log Out',
              style: roboto(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE02850),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Edit Profile Sheet
// ═════════════════════════════════════════════════════════════════════════════
class _EditProfileSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final void Function(String name, String phone) onSave;
  const _EditProfileSheet({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final btm = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, btm + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text(
            'Edit Profile',
            style: roboto(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          // Avatar
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kBlue, kLightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_rounded, size: 15, color: kBlue),
            label: Text(
              'Change Photo',
              style: roboto(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kBlue,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SheetField(
            controller: nameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: phoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _SheetPrimaryBtn(
            label: 'Save Changes',
            onTap: () => onSave(nameCtrl.text.trim(), phoneCtrl.text.trim()),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Change Password Sheet
// ═════════════════════════════════════════════════════════════════════════════
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCur = true, _obscureNew = true, _obscureConf = true;

  @override
  Widget build(BuildContext context) {
    final btm = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, btm + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text(
            'Change Password',
            style: roboto(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(
            controller: _currentCtrl,
            label: 'Current Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureCur,
            suffix: IconButton(
              icon: Icon(
                _obscureCur
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.grey.shade400,
              ),
              onPressed: () => setState(() => _obscureCur = !_obscureCur),
            ),
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _newCtrl,
            label: 'New Password',
            icon: Icons.lock_rounded,
            obscure: _obscureNew,
            suffix: IconButton(
              icon: Icon(
                _obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.grey.shade400,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _confirmCtrl,
            label: 'Confirm New Password',
            icon: Icons.lock_reset_rounded,
            obscure: _obscureConf,
            suffix: IconButton(
              icon: Icon(
                _obscureConf
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.grey.shade400,
              ),
              onPressed: () => setState(() => _obscureConf = !_obscureConf),
            ),
          ),
          const SizedBox(height: 20),
          _SheetPrimaryBtn(
            label: 'Update Password',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: kBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Add Card Sheet
// ═════════════════════════════════════════════════════════════════════════════
class _AddCardSheet extends StatelessWidget {
  final void Function(Map<String, String>) onSave;
  const _AddCardSheet({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final btm = MediaQuery.of(context).viewInsets.bottom;
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, btm + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kBlue, kLightBlue]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add Payment Card',
                style: roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SheetField(
            controller: numberCtrl,
            label: 'Card Number',
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: nameCtrl,
            label: 'Card Holder Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetField(
                  controller: expiryCtrl,
                  label: 'MM/YY',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetField(
                  controller: cvvCtrl,
                  label: 'CVV',
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.number,
                  obscure: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SheetPrimaryBtn(
            label: 'Save Card',
            onTap: () {
              final num = numberCtrl.text.trim();
              onSave({
                'type': num.startsWith('4') ? 'Visa' : 'Mastercard',
                'last4': num.length >= 4
                    ? num.substring(num.length - 4)
                    : '0000',
                'expiry': expiryCtrl.text.trim(),
                'default': 'false',
              });
            },
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Confirm Sheet (Logout / Switch Account)
// ═════════════════════════════════════════════════════════════════════════════
class _ConfirmSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, body, confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  const _ConfirmSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 20),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: roboto(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: roboto(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: confirmColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        confirmLabel,
                        style: roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Shared sheet helpers
// ═════════════════════════════════════════════════════════════════════════════
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: roboto(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: roboto(fontSize: 13, color: Colors.grey.shade500),
        prefixIcon: Icon(icon, size: 18, color: kBlue),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: kBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _SheetPrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SheetPrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kBlue, kLightBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kBlue.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: roboto(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
