import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import '../services/smooth_navigation.dart';
import '../services/ui_translation.dart';
import '../services/trip_service.dart';
import '../services/groq_chat_service.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';
import '../models/booking_model.dart';
import '../models/trip_model.dart';

// ── ChatBot external controller ───────────────────────────────────────────────
class ChatBotController {
  void Function(String)? _sendFn;
  void send(String text) {
    _sendFn?.call(text);
  }
}

// ── Groq AI service ────────────────────────────────────────────────────────
const _kChatBackgroundAsset = 'img/Background.png';

class _GeminiChat {
  final GroqChatService _service = GroqChatService();

  Future<String> send(String message, {required String tripContext}) async {
    try {
      return await _service.sendMessage(message, tripContext: tripContext);
    } on GroqChatException catch (e) {
      return e.message;
    }
  }
}

// ── Quick suggestion chips ─────────────────────────────────────────────────
const _kChips = [
  (Icons.flight_rounded, 'Flying Taxi'),
  (Icons.directions_bus_rounded, 'Transit Trips'),
  (Icons.calendar_today_rounded, 'My Bookings'),
  (Icons.place_rounded, 'Popular Places'),
  (Icons.attach_money_rounded, 'Prices'),
];

String _buildTripContext(List<TripModel> trips) {
  if (trips.isEmpty) {
    return 'TRIP DATA STATUS: unavailable in this request. Do not claim that a trip is unavailable. Say that trip availability is being refreshed and ask the user to try again.';
  }

  final buffer = StringBuffer(
    'AVAILABLE TRIPS (only mention these; do not invent):\n',
  );
  for (final trip in trips) {
    buffer.writeln(
      '- ${trip.name} | type: ${trip.type.name} | duration: ${trip.durationLabel} | price: ${trip.priceLabel} | route: ${trip.routeLabel}',
    );
    if (trip.shortDescription.trim().isNotEmpty) {
      buffer.writeln('  info: ${trip.shortDescription}');
    }
  }
  buffer.writeln(
    'RULES: If user asks about a trip not in the list, say it is not available in the app. Use only the list for prices/durations.',
  );
  return buffer.toString();
}

String _buildBookingContext(List<Booking> bookings) {
  if (bookings.isEmpty) {
    return 'CURRENT USER BOOKINGS: none loaded. Do not claim that a booking exists. Direct the user to My Bookings to view or create one.';
  }

  final buffer = StringBuffer('CURRENT USER BOOKINGS:\n');
  for (final booking in bookings) {
    buffer.writeln(
      '- trip: ${booking.tripName} | date: ${booking.date.toIso8601String()} | time: ${booking.time} | status: ${booking.status.name} | travelers: ${booking.travelers}',
    );
  }
  buffer.writeln(
    'Do not change or cancel a booking from chat. Direct the user to My Bookings for actions.',
  );
  return buffer.toString();
}

// ── Public entry-point ─────────────────────────────────────────────────────
void showChatBot(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) => const _ChatBotSheet(),
  );
}

// ── Full-page chatbot route with slide-up animation ────────────────────────
void openChatBotFullPage(BuildContext context) {
  SmoothNavigation.slideUp(
    context,
    (context) => const ChatBotPage(),
    routeName: 'chatbot_fullpage',
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  Full-page ChatBot
// ═════════════════════════════════════════════════════════════════════════════
class ChatBotPage extends StatefulWidget {
  final ChatBotController? controller;
  final VoidCallback? onBack;
  const ChatBotPage({super.key, this.controller, this.onBack});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  final _gemini = _GeminiChat();

  final List<_ChatMsg> _msgs = [
    _ChatMsg(
      text:
          'Hello! 👋 Welcome to App Transport, your Egypt travel companion.\nAsk me about tours, landmarks, transportation, or bookings across Egypt!',
      isUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller?._sendFn = _send;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripService>().loadTrips();
    });
  }

  @override
  void dispose() {
    widget.controller?._sendFn = null;
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_ChatMsg(text: msg, isUser: true));
      _typing = true;
    });
    _scrollToBottom();

    final tripService = context.read<TripService>();
    final bookingService = context.read<BookingService>();
    final auth = context.read<AuthService>();
    if (tripService.isLoading) {
      await tripService.loadTrips();
    }
    if (auth.currentUser != null && bookingService.bookings.isEmpty) {
      await bookingService.loadBookings(auth.currentUser!.uid);
    }
    final tripContext =
        '${_buildTripContext(tripService.activeTrips)}\n${_buildBookingContext(bookingService.bookings)}';
    final reply = await _gemini.send(msg, tripContext: tripContext);
    if (!mounted) return;

    setState(() {
      _typing = false;
      _msgs.add(_ChatMsg(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TripService>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Column(
        children: [
          // Header with status bar padding
          _Header(
            onClose: widget.onBack ?? () => Navigator.pop(context),
            fullPage: true,
            useBackStyle: true,
          ),
          // Chips
          _ChipsRow(onChip: _send),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_typing && i == _msgs.length) {
                  return const _TypingBubble();
                }
                return _Bubble(msg: _msgs[i]);
              },
            ),
          ),
          // Input
          _InputBar(controller: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Chat Message model
// ═════════════════════════════════════════════════════════════════════════════
class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg({required this.text, required this.isUser});
}

// ═════════════════════════════════════════════════════════════════════════════
//  Bottom-sheet shell
// ═════════════════════════════════════════════════════════════════════════════
class _ChatBotSheet extends StatefulWidget {
  const _ChatBotSheet();

  @override
  State<_ChatBotSheet> createState() => _ChatBotSheetState();
}

class _ChatBotSheetState extends State<_ChatBotSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  final _gemini = _GeminiChat();

  final List<_ChatMsg> _msgs = [
    _ChatMsg(
      text:
          'Hello! 👋 Welcome to App Transport, your Egypt travel companion.\nAsk me about tours, landmarks, transportation, or bookings across Egypt!',
      isUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripService>().loadTrips();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_ChatMsg(text: msg, isUser: true));
      _typing = true;
    });
    _scrollToBottom();

    final tripService = context.read<TripService>();
    final bookingService = context.read<BookingService>();
    final auth = context.read<AuthService>();
    if (tripService.isLoading) {
      await tripService.loadTrips();
    }
    if (auth.currentUser != null && bookingService.bookings.isEmpty) {
      await bookingService.loadBookings(auth.currentUser!.uid);
    }
    final tripContext =
        '${_buildTripContext(tripService.activeTrips)}\n${_buildBookingContext(bookingService.bookings)}';
    final reply = await _gemini.send(msg, tripContext: tripContext);
    if (!mounted) return;

    setState(() {
      _typing = false;
      _msgs.add(_ChatMsg(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TripService>();
    final btm = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height * 0.74;

    return Padding(
      padding: EdgeInsets.only(bottom: btm),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_kChatBackgroundAsset),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            color: Color(0xFFF5F5F5),
          ),
          child: Container(
            color: Colors.white.withValues(alpha: 0.28),
            child: Column(
              children: [
                // drag handle
                const SizedBox(height: 10),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Header
                _Header(onClose: () => Navigator.pop(context)),
                // Chips
                _ChipsRow(onChip: _send),
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    itemCount: _msgs.length + (_typing ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (_typing && i == _msgs.length) {
                        return const _TypingBubble();
                      }
                      return _Bubble(msg: _msgs[i]);
                    },
                  ),
                ),
                // Input
                _InputBar(controller: _ctrl, onSend: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final bool fullPage;
  final bool useBackStyle;
  const _Header({
    required this.onClose,
    this.fullPage = false,
    this.useBackStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = fullPage ? MediaQuery.of(context).padding.top : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(18, topPad + 16, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBlue, kLightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: fullPage
            ? null
            : const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          // Bot avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UiTranslation.display(context, 'App Assistant'),
                  style: roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4DF08C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      UiTranslation.display(
                        context,
                        'Online - AI Travel Guide',
                      ),
                      style: roboto(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Share / options
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          // Close / back
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: useBackStyle ? 44 : 36,
              height: useBackStyle ? 44 : 36,
              decoration: BoxDecoration(
                color: useBackStyle
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.18),
                shape: useBackStyle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: useBackStyle ? null : BorderRadius.circular(10),
                boxShadow: useBackStyle
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                useBackStyle
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.close_rounded,
                color: useBackStyle ? const Color(0xFF1A1A2E) : Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chips row ────────────────────────────────────────────────────────────────
class _ChipsRow extends StatelessWidget {
  final void Function(String) onChip;
  const _ChipsRow({required this.onChip});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _kChips.map((c) {
            return GestureDetector(
              onTap: () => onChip(c.$2),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: kBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBlue.withValues(alpha: 0.20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.$1, size: 13, color: kBlue),
                    const SizedBox(width: 5),
                    Text(
                      UiTranslation.display(context, c.$2),
                      style: roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Message bubble ──────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final _ChatMsg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // Bot avatar
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kBlue, kLightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? null : Colors.white,
                gradient: isUser
                    ? const LinearGradient(
                        colors: [kBlue, kLightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? kBlue : Colors.black).withValues(
                      alpha: 0.10,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: isUser
                    ? null
                    : Border.all(color: const Color(0xFFE3ECF5)),
              ),
              child: isUser
                  ? Text(
                      msg.text,
                      style: roboto(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    )
                  : MarkdownBody(
                      data: UiTranslation.display(context, msg.text),
                      selectable: true,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: roboto(
                          fontSize: 13,
                          color: const Color(0xFF1A1A2E),
                          height: 1.5,
                        ),
                        h1: roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102A43),
                        ),
                        h2: roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102A43),
                        ),
                        h3: roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF102A43),
                        ),
                        listBullet: roboto(
                          fontSize: 13,
                          color: kBlue,
                          fontWeight: FontWeight.w700,
                        ),
                        strong: roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF102A43),
                        ),
                        tableHead: roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        tableBody: roboto(
                          fontSize: 12,
                          color: const Color(0xFF1A1A2E),
                          height: 1.35,
                        ),
                        tableBorder: TableBorder.all(
                          color: const Color(0xFFD9E2EC),
                          width: 1,
                        ),
                        tableHeadAlign: TextAlign.left,
                        blockSpacing: 8,
                        blockquote: roboto(
                          fontSize: 13,
                          color: const Color(0xFF486581),
                          height: 1.5,
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─── Typing indicator ─────────────────────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kBlue, kLightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (ctx, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final phase = (_anim.value * 3 - i).clamp(0.0, 1.0);
                  final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                  return Transform.translate(
                    offset: Offset(0, -4 * t),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kBlue.withValues(alpha: 0.35 + 0.65 * t),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final btmPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(14, 10, 14, btmPad + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: onSend,
                style: roboto(fontSize: 13),
                decoration: InputDecoration(
                  hintText: UiTranslation.display(context, 'Chat here...'),
                  hintStyle: roboto(fontSize: 13, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: () => onSend(controller.text),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kBlue, kLightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: kBlue, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
