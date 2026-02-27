import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';

// ── Booking Status ────────────────────────────────────────────────────────────
enum BookingStatus { upcoming, completed, cancelled }

// ── Booking Model ─────────────────────────────────────────────────────────────
class Booking {
  final String id;
  final String tripName;
  final String tripImage;
  final DateTime date;
  final String time;
  int travelers;
  final double pricePerPerson;
  final String paymentMethod;
  final String pickupLocation;
  final String dropoffLocation;
  final String routeLabel;
  final Color accentColor;
  BookingStatus status;
  double userRating;
  String userReview;

  Booking({
    required this.id,
    required this.tripName,
    required this.tripImage,
    required this.date,
    required this.time,
    required this.travelers,
    required this.pricePerPerson,
    required this.paymentMethod,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.routeLabel,
    required this.accentColor,
    this.status = BookingStatus.upcoming,
    this.userRating = 0,
    this.userReview = '',
  });

  double get totalPrice => pricePerPerson * travelers;
  String get totalPriceLabel => '\$${totalPrice.toInt()}';
  String get priceLabel => '\$${pricePerPerson.toInt()}';
}

// ── Sample data ───────────────────────────────────────────────────────────────
final _sampleBookings = <Booking>[
  Booking(
    id: 'TRX-45821',
    tripName: 'Giza Pyramids, NMEC & Nile Corniche',
    tripImage:
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800&q=80',
    date: DateTime.now().add(const Duration(days: 5)),
    time: '10:00 AM',
    travelers: 2,
    pricePerPerson: 90,
    paymentMethod: 'Visa •••• 4242',
    pickupLocation: 'Cairo International Airport',
    dropoffLocation: 'Cairo International Airport',
    routeLabel: 'Airport → Pyramids → NMEC → Nile → Airport',
    accentColor: const Color(0xFFD4A843),
  ),
  Booking(
    id: 'TRX-38204',
    tripName: 'Old Cairo & Khan El-Khalili Bazaar',
    tripImage:
        'https://images.unsplash.com/photo-1539768942893-daf53e448371?w=800&q=80',
    date: DateTime.now().add(const Duration(days: 12)),
    time: '09:00 AM',
    travelers: 1,
    pricePerPerson: 65,
    paymentMethod: 'Mastercard •••• 7890',
    pickupLocation: 'Cairo International Airport',
    dropoffLocation: 'Cairo International Airport',
    routeLabel: 'Airport → Old Cairo → Khan El-Khalili → Airport',
    accentColor: const Color(0xFF4A44AA),
  ),
  Booking(
    id: 'TRX-29174',
    tripName: 'Luxor Temples & Valley of Kings',
    tripImage:
        'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=800&q=80',
    date: DateTime.now().subtract(const Duration(days: 18)),
    time: '07:00 AM',
    travelers: 3,
    pricePerPerson: 250,
    paymentMethod: 'Visa •••• 1111',
    pickupLocation: 'Cairo International Airport',
    dropoffLocation: 'Cairo International Airport',
    routeLabel: 'Fly to Luxor → Karnak → Valley of Kings → Return',
    accentColor: const Color(0xFFE02850),
    status: BookingStatus.completed,
    userRating: 5,
    userReview: 'Amazing experience! The temples were breathtaking.',
  ),
  Booking(
    id: 'TRX-11053',
    tripName: 'Cairo Tower & Nile Felucca Cruise',
    tripImage:
        'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800&q=80',
    date: DateTime.now().subtract(const Duration(days: 40)),
    time: '02:00 PM',
    travelers: 2,
    pricePerPerson: 55,
    paymentMethod: 'Cash on pickup',
    pickupLocation: 'Cairo International Airport',
    dropoffLocation: 'Cairo International Airport',
    routeLabel: 'Airport → Cairo Tower → Nile Cruise → Airport',
    accentColor: const Color(0xFF187BCD),
    status: BookingStatus.completed,
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
//  MyBookingsPage
// ═════════════════════════════════════════════════════════════════════════════
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final List<Booking> _bookings;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _bookings = List.from(_sampleBookings);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<Booking> get _upcoming =>
      _bookings.where((b) => b.status == BookingStatus.upcoming).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<Booking> get _past =>
      _bookings
          .where(
            (b) =>
                b.status == BookingStatus.completed ||
                b.status == BookingStatus.cancelled,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ── Cancel flow ───────────────────────────────────────────────────────────
  void _showCancelDialog(Booking b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE02850).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFE02850),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cancel Booking?',
              style: roboto(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to cancel\n"${b.tripName}"?',
              textAlign: TextAlign.center,
              style: roboto(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD4A843),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free cancellation up to 2 hours before departure.',
                      style: roboto(
                        fontSize: 12,
                        color: const Color(0xFF856404),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Booking',
              style: roboto(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => b.status = BookingStatus.cancelled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking #${b.id} cancelled.',
                    style: roboto(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFE02850),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE02850),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            ),
            child: Text(
              'Confirm Cancel',
              style: roboto(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modify flow ───────────────────────────────────────────────────────────
  void _showModifyDialog(Booking b) {
    TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 0);
    int travelers = b.travelers;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Icon(Icons.edit_calendar_rounded, color: kBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Modify Booking',
                style: roboto(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b.tripName,
                style: roboto(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Time
              Text(
                'Departure Time',
                style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) setS(() => selectedTime = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBlue.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: kBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime.format(context),
                        style: roboto(
                          fontWeight: FontWeight.w600,
                          color: kBlue,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Travelers
              Text(
                'Number of Travelers',
                style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBlue.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_rounded, color: kBlue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$travelers Adult${travelers > 1 ? 's' : ''}',
                      style: roboto(fontWeight: FontWeight.w600, color: kBlue),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setS(() {
                            if (travelers > 1) travelers--;
                          }),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: travelers > 1
                                  ? kBlue
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.remove_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$travelers',
                          style: roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setS(() {
                            if (travelers < 10) travelers++;
                          }),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: kBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Updated price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    Text(
                      'Updated total: ',
                      style: roboto(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    Text(
                      '\$${(b.pricePerPerson * travelers).toInt()} USD',
                      style: roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: roboto(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => b.travelers = travelers);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking updated successfully!',
                      style: roboto(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
              ),
              child: Text(
                'Save Changes',
                style: roboto(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Review flow ───────────────────────────────────────────────────────────
  void _showReviewDialog(Booking b) {
    double star = b.userRating == 0 ? 5 : b.userRating;
    final ctrl = TextEditingController(text: b.userReview);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC107),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Leave a Review',
                style: roboto(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b.tripName,
                style: roboto(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Rating',
                style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setS(() => star = (i + 1).toDouble()),
                    child: Icon(
                      i < star ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFC107),
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Comment',
                style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience…',
                  hintStyle: roboto(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Skip', style: roboto(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  b.userRating = star;
                  b.userReview = ctrl.text.trim();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Thank you for your review! ⭐',
                      style: roboto(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFD4A843),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
              ),
              child: Text('Submit', style: roboto(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── View Details ──────────────────────────────────────────────────────────
  void _openDetail(Booking b) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (c, a, s) => _BookingDetailPage(
          booking: b,
          onCancel: () {
            Navigator.pop(c);
            _showCancelDialog(b);
          },
          onModify: () {
            Navigator.pop(c);
            _showModifyDialog(b);
          },
          formatDate: _formatDate,
        ),
        transitionsBuilder: (c, a, s, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xFFE8F4F8),
          child: Column(
            children: [
              // ── Header + tabs ──────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0B000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(22, topPad + 16, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'My Bookings',
                          style: roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 22,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and manage all your trips',
                      style: roboto(fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 16),

                    // Tabs
                    TabBar(
                      controller: _tab,
                      labelStyle: roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      labelColor: kBlue,
                      unselectedLabelColor: Colors.grey.shade500,
                      indicatorColor: kBlue,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.upcoming_rounded, size: 16),
                              const SizedBox(width: 6),
                              const Text('Upcoming'),
                              const SizedBox(width: 6),
                              _CountBadge(
                                count: _upcoming.length,
                                color: kBlue,
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.history_rounded, size: 16),
                              const SizedBox(width: 6),
                              const Text('Past'),
                              const SizedBox(width: 6),
                              _CountBadge(
                                count: _past.length,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Tab content ────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _UpcomingTab(
                      bookings: _upcoming,
                      formatDate: _formatDate,
                      onView: _openDetail,
                      onModify: _showModifyDialog,
                      onCancel: _showCancelDialog,
                    ),
                    _PastTab(
                      bookings: _past,
                      formatDate: _formatDate,
                      onReview: _showReviewDialog,
                      onView: _openDetail,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Count badge
// ═════════════════════════════════════════════════════════════════════════════
class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: roboto(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Upcoming tab
// ═════════════════════════════════════════════════════════════════════════════
class _UpcomingTab extends StatelessWidget {
  final List<Booking> bookings;
  final String Function(DateTime) formatDate;
  final void Function(Booking) onView;
  final void Function(Booking) onModify;
  final void Function(Booking) onCancel;

  const _UpcomingTab({
    required this.bookings,
    required this.formatDate,
    required this.onView,
    required this.onModify,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyState(tab: 'upcoming');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: bookings.length,
      itemBuilder: (context, i) {
        final b = bookings[i];
        return _UpcomingCard(
          booking: b,
          formatDate: formatDate,
          onView: () => onView(b),
          onModify: () => onModify(b),
          onCancel: () => onCancel(b),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Upcoming Booking Card
// ═════════════════════════════════════════════════════════════════════════════
class _UpcomingCard extends StatelessWidget {
  final Booking booking;
  final String Function(DateTime) formatDate;
  final VoidCallback onView;
  final VoidCallback onModify;
  final VoidCallback onCancel;

  const _UpcomingCard({
    required this.booking,
    required this.formatDate,
    required this.onView,
    required this.onModify,
    required this.onCancel,
  });

  int get _daysLeft => booking.date.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final days = _daysLeft;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: b.accentColor.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          // ── Image + countdown ────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Image.network(
                  b.tripImage,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          b.accentColor,
                          b.accentColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Booking ID
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${b.id}',
                      style: roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Countdown
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: days <= 3
                          ? const Color(0xFFE02850)
                          : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      days == 0
                          ? 'Today!'
                          : days == 1
                          ? 'Tomorrow'
                          : 'In $days days',
                      style: roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Bottom info
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    b.tripName,
                    style: roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Details grid ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    _DetailCell(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: formatDate(b.date),
                      color: kBlue,
                    ),
                    const SizedBox(width: 10),
                    _DetailCell(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: b.time,
                      color: const Color(0xFF4A44AA),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _DetailCell(
                      icon: Icons.people_rounded,
                      label: 'Travelers',
                      value:
                          '${b.travelers} Adult${b.travelers > 1 ? 's' : ''}',
                      color: const Color(0xFF0D7377),
                    ),
                    const SizedBox(width: 10),
                    _DetailCell(
                      icon: Icons.attach_money_rounded,
                      label: 'Total',
                      value: b.totalPriceLabel,
                      color: const Color(0xFFE87832),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Pickup location
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight_land_rounded,
                        color: kBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pickup: ',
                        style: roboto(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          b.pickupLocation,
                          style: roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────
          Divider(color: Colors.grey.shade100, height: 1),

          // ── Action buttons ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: 'View Details',
                    icon: Icons.visibility_rounded,
                    color: kBlue,
                    outlined: false,
                    onTap: onView,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionBtn(
                    label: 'Modify',
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF4A44AA),
                    outlined: true,
                    onTap: onModify,
                  ),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Cancel',
                  icon: Icons.close_rounded,
                  color: const Color(0xFFE02850),
                  outlined: true,
                  compact: true,
                  onTap: onCancel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Past tab
// ═════════════════════════════════════════════════════════════════════════════
class _PastTab extends StatelessWidget {
  final List<Booking> bookings;
  final String Function(DateTime) formatDate;
  final void Function(Booking) onReview;
  final void Function(Booking) onView;

  const _PastTab({
    required this.bookings,
    required this.formatDate,
    required this.onReview,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _EmptyState(tab: 'past');
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      itemCount: bookings.length,
      itemBuilder: (context, i) {
        final b = bookings[i];
        return _PastCard(
          booking: b,
          formatDate: formatDate,
          onReview: () => onReview(b),
          onView: () => onView(b),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Past Booking Card
// ═════════════════════════════════════════════════════════════════════════════
class _PastCard extends StatelessWidget {
  final Booking booking;
  final String Function(DateTime) formatDate;
  final VoidCallback onReview;
  final VoidCallback onView;

  const _PastCard({
    required this.booking,
    required this.formatDate,
    required this.onReview,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final isCancelled = b.status == BookingStatus.cancelled;
    final statusColor = isCancelled
        ? const Color(0xFFE02850)
        : Colors.green.shade600;
    final statusLabel = isCancelled ? 'Cancelled' : 'Completed';
    final statusIcon = isCancelled
        ? Icons.cancel_rounded
        : Icons.check_circle_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: ColorFiltered(
              colorFilter: isCancelled
                  ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  : const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.saturation,
                    ),
              child: Image.network(
                b.tripImage,
                width: 95,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 95,
                  height: 130,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b.tripName,
                    style: roboto(fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(b.date),
                        style: roboto(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      Text(
                        b.totalPriceLabel,
                        style: roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const Spacer(),
                      // Star if rated
                      if (b.userRating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC107),
                              size: 14,
                            ),
                            Text(
                              ' ${b.userRating.toStringAsFixed(0)}',
                              style: roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Buttons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onView,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kBlue.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Details',
                            style: roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kBlue,
                            ),
                          ),
                        ),
                      ),
                      if (!isCancelled) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onReview,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFC107,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFD4A843),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  b.userRating > 0
                                      ? 'Edit Review'
                                      : 'Leave Review',
                                  style: roboto(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD4A843),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Booking Detail Page
// ═════════════════════════════════════════════════════════════════════════════
class _BookingDetailPage extends StatelessWidget {
  final Booking booking;
  final VoidCallback onCancel;
  final VoidCallback onModify;
  final String Function(DateTime) formatDate;

  const _BookingDetailPage({
    required this.booking,
    required this.onCancel,
    required this.onModify,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final topPad = MediaQuery.of(context).padding.top;
    final btmPad = MediaQuery.of(context).padding.bottom;
    final isUpcoming = b.status == BookingStatus.upcoming;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8FC),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Hero
                  SizedBox(
                    height: 220,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          b.tripImage,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  b.accentColor,
                                  b.accentColor.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: topPad + 12,
                          left: 18,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.40),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 18,
                          right: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.tripName,
                                style: roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Booking ID + status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: kBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.receipt_rounded,
                                    size: 15,
                                    color: kBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '#${b.id}',
                                    style: roboto(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: kBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? Colors.green.withValues(alpha: 0.10)
                                    : const Color(
                                        0xFFE02850,
                                      ).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isUpcoming ? 'Upcoming' : 'Completed',
                                style: roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isUpcoming
                                      ? Colors.green.shade700
                                      : const Color(0xFFE02850),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Info rows
                        _SectionTitle('Trip Information'),
                        const SizedBox(height: 12),
                        _InfoRow(
                          Icons.calendar_today_rounded,
                          'Date',
                          formatDate(b.date),
                          kBlue,
                        ),
                        _InfoRow(
                          Icons.access_time_rounded,
                          'Time',
                          b.time,
                          const Color(0xFF4A44AA),
                        ),
                        _InfoRow(
                          Icons.people_rounded,
                          'Travelers',
                          '${b.travelers} Adult${b.travelers > 1 ? 's' : ''}',
                          const Color(0xFF0D7377),
                        ),
                        _InfoRow(
                          Icons.attach_money_rounded,
                          'Total Price',
                          '${b.totalPriceLabel} USD',
                          const Color(0xFFE87832),
                        ),
                        _InfoRow(
                          Icons.credit_card_rounded,
                          'Payment Method',
                          b.paymentMethod,
                          kBlue,
                        ),
                        const SizedBox(height: 20),

                        _SectionTitle('Pickup & Drop-off'),
                        const SizedBox(height: 12),
                        _RouteCard(b: b),
                        const SizedBox(height: 20),

                        _SectionTitle('Route'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.route_rounded,
                                color: b.accentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  b.routeLabel,
                                  style: roboto(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (isUpcoming) ...[
                          // Contact support
                          GestureDetector(
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Connecting to support…',
                                      style: roboto(color: Colors.white),
                                    ),
                                    backgroundColor: kBlue,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.support_agent_rounded,
                                    color: Color(0xFF4A44AA),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contact Support',
                                    style: roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4A44AA),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: btmPad + 90),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pinned buttons (only for upcoming)
            if (isUpcoming)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, btmPad + 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onModify,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4A44AA,
                              ).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(
                                  0xFF4A44AA,
                                ).withValues(alpha: 0.30),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Modify',
                                style: roboto(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4A44AA),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE02850), Color(0xFFFF6B81)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE02850,
                                  ).withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Cancel Booking',
                                style: roboto(
                                  fontSize: 15,
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: roboto(fontSize: 16, fontWeight: FontWeight.w700));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Text(
            '$label  ',
            style: roboto(fontSize: 13, color: Colors.grey.shade500),
          ),
          Expanded(
            child: Text(
              value,
              style: roboto(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final Booking b;
  const _RouteCard({required this.b});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: kBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 36, color: Colors.grey.shade200),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFE02850),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup',
                  style: roboto(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  b.pickupLocation,
                  style: roboto(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drop-off',
                  style: roboto(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  b.dropoffLocation,
                  style: roboto(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: roboto(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  Text(
                    value,
                    style: roboto(fontSize: 12, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool compact;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.outlined,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 0,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: outlined ? color.withValues(alpha: 0.08) : color,
          borderRadius: BorderRadius.circular(12),
          border: outlined
              ? Border.all(color: color.withValues(alpha: 0.30))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: outlined ? color : Colors.white),
            if (!compact) ...[
              const SizedBox(width: 5),
              Text(
                label,
                style: roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Empty State
// ═════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tab == 'upcoming' ? Icons.luggage_rounded : Icons.history_rounded,
              size: 48,
              color: kBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tab == 'upcoming'
                ? "You don't have any\nbookings yet"
                : "No past trips found",
            textAlign: TextAlign.center,
            style: roboto(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tab == 'upcoming'
                ? 'Explore available trips and book your\nnext layover adventure!'
                : 'Completed trips will appear here',
            textAlign: TextAlign.center,
            style: roboto(fontSize: 13, color: Colors.grey.shade500),
          ),
          if (tab == 'upcoming') ...[
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF187BCD), Color(0xFF5BC0EB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kBlue.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Explore Trips',
                  style: roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
