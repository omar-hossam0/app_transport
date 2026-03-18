import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_widgets.dart';
import '../config.dart';

// ── ChatBot external controller ───────────────────────────────────────────────
class ChatBotController {
  void Function(String)? _sendFn;
  void send(String text) {
    _sendFn?.call(text);
  }
}

// ── Groq AI service ────────────────────────────────────────────────────────
const _kGroqApiKey = kGroqApiKey;
const _kGroqModel = 'llama-3.3-70b-versatile';
const _kChatBackgroundAsset = 'img/Background.png';

const _kSystemPrompt = '''
You are a friendly specialized digital assistant for App Transport, a tourism application dedicated to Egypt.
Your function is to help travelers explore and book tours in Egypt.

ALLOWED interactions:
1. Greetings and farewells (hello, hi, اهلا, مرحبا, bye, etc.) — respond warmly and invite the user to ask about Egypt tourism
2. Tour packages and trips within Egypt
3. Booking transportation and travel between Egyptian cities
4. Information about landmarks and tourist sites in Egypt
5. The app's Flying Taxi aerial tours and Transit day trips
6. General travel tips for visiting Egypt

App Transport offers:
- Flying Taxi aerial tours departing from Cairo Airport (Giza Pyramids, Alexandria, Luxor, Siwa, Aswan, Hurghada, etc.) starting from \$75
- Transit day trips: Giza Pyramids + NMEC (8h/\$90), Old Cairo + Khan El-Khalili (5h/\$65), Cairo Tower + Felucca (4h/\$55), Saladin Citadel (5h/\$70), Memphis + Saqqara + Dahshur (8h/\$100)
- All trips include airport pickup, certified English-speaking guide, and entry tickets
- Free cancellation up to 2 hours before departure

MANDATORY RULES:
- For greetings, respond warmly and briefly mention you are the Egypt travel assistant, then ask how you can help with their trip
- You are STRICTLY FORBIDDEN from answering anything unrelated to tourism or travel within Egypt
- For ANY off-topic question (politics, sports, technology, weather, coding, etc.), respond ONLY with: "I specialize only in tourism and travel within Egypt. I cannot answer that. Do you have a tourism-related question?"
- Do NOT apologize. Do NOT explain further for off-topic refusals.
- Give accurate, concise, and helpful answers for travelers in Egypt
- Always respond in the SAME LANGUAGE the user writes in (Arabic or English)
''';

class _GeminiChat {
  final List<Map<String, String>> _history = [];

  Future<String> send(String message) async {
    _history.add({'role': 'user', 'content': message});
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_kGroqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _kGroqModel,
          'messages': [
            {'role': 'system', 'content': _kSystemPrompt},
            ..._history,
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': reply});
        return reply.trim();
      } else {
        _history.removeLast();
        return 'Error ${response.statusCode}. Please try again. 🔌';
      }
    } catch (e) {
      _history.removeLast();
      return 'Connection error. Please check your internet and try again. 🔌';
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

// ── (Keyword responses replaced by Gemini AI) ───────────────────────────────
const kResponses = {
  'flying taxi':
      'We offer flying taxi aerial tours departing from Cairo Airport! Choose from 10 breathtaking destinations including the Giza Pyramids, Alexandria, Luxor, Siwa Oasis, Aswan, Hurghada and more. Prices start from \$75. Tap "Flying Taxi" in the bottom nav to explore all trips! ✈️',
  'flying':
      'Our Flying Taxi service takes you on scenic aerial tours across Egypt — all departing from Cairo Airport. From a 7-hour Fayoum loop to a 20-hour Siwa oasis journey, there\'s a trip for every layover length. 🚁',
  'taxi':
      'Our Flying Taxi service takes you on scenic aerial tours across Egypt — all departing from Cairo Airport. Prices start at \$75 per person. ✈️',
  'transit':
      'Our Transit Trips are guided land day-tours perfect for layovers! We offer 5 curated routes:\n• Giza Pyramids + NMEC (8h / \$90)\n• Old Cairo + Khan El-Khalili (5h / \$65)\n• Cairo Tower + Felucca Cruise (4h / \$55)\n• Saladin Citadel + Islamic Cairo (5h / \$70)\n• Memphis, Saqqara & Dahshur (8h / \$100)\nTap "Trips" in the bottom nav to book! 🚌',
  'booking':
      'You can view and manage all your bookings in the "Bookings" tab. You\'ll find upcoming and past trips, with options to modify your booking (change time or traveler count) or cancel for free up to 2 hours before departure. 📋',
  'cancel':
      'Free cancellation is available up to 2 hours before your trip departure. Head to "Bookings" → select your trip → tap "Cancel Booking" to confirm. A full refund will be processed within 3-5 business days. 💳',
  'modify':
      'To modify a booking, go to "Bookings" → select your upcoming trip → tap "Modify". You can change the departure time and number of travelers. The updated total price will be shown before you confirm. ✏️',
  'price':
      'Our trip prices range from:\n• \$55 — Cairo Tower + Felucca Cruise (4h)\n• \$65 — Old Cairo + Khan El-Khalili (5h)\n• \$70 — Saladin Citadel (5h)\n• \$90 — Giza Pyramids + NMEC (8h)\n• \$100 — Memphis + Saqqara + Dahshur (8h)\nFlying Taxi tours start from \$75 up to \$300. 💰',
  'prices':
      'Our trip prices range from \$55 to \$300 per person depending on the destination and duration. All prices include airport pickup, a certified guide, and entry tickets. 💰',
  'egypt':
      'Egypt is an incredible layover destination! 🌟 Whether you have 4 hours or a full day, we have the perfect tour:\n• Short layover (4h): Cairo Tower + Nile Cruise\n• Medium (5-6h): Old Cairo or Saladin Citadel\n• Full day (8h+): Pyramids of Giza or Memphis/Saqqara',
  'cairo':
      'Cairo is our hub city! All trips depart from Cairo International Airport. The city offers amazing experiences from the iconic Giza Pyramids to the medieval Islamic quarter of Khan El-Khalili. 🕌',
  'pyramids':
      'The Giza Pyramids tour is our most popular trip! 🏛️ The 8-hour "Giza Pyramids, NMEC & Nile Corniche" experience is priced at \$90/person and includes a visit to the Grand Egyptian Museum, the Sphinx, and a relaxing Nile walk. Book it in the "Trips" tab!',
  'luxor':
      'Our Luxor flying taxi tour (16h / \$250) departs from Cairo Airport and covers the Karnak Temple complex and Valley of the Kings — where pharaohs including Tutankhamun are buried. A truly once-in-a-lifetime experience! 🏺',
  'hello':
      'Hello! 👋 Welcome to App Transport — your layover travel companion. I can help you explore our Flying Taxi tours, Transit day trips, manage bookings, or answer any questions. What would you like to know?',
  'hi':
      'Hi there! 😊 I\'m your AI travel assistant. Ask me anything about:\n• Flying Taxi aerial tours\n• Transit day trips\n• Booking management\n• Destinations and prices',
  'help':
      'Of course! Here\'s what I can help with:\n✈️ Flying Taxi tours\n🚌 Transit day trips\n📋 Booking management (view, modify, cancel)\n💰 Pricing info\n📍 Egyptian destinations\n\nJust type your question or tap a suggestion chip above!',
  'airport':
      'All our trips depart from and return to Cairo International Airport (CAI — Terminal 2). Our drivers will meet you at the arrivals hall with a name sign. No foreign SIM card needed — just show your booking ID! 🛫',
  'include':
      'Our trip packages include:\n✅ Airport pickup & drop-off\n✅ Private or shared vehicle\n✅ Certified English-speaking guide\n✅ Entry tickets to all sites\n✅ Bottled water\nSome longer tours also include a light lunch or traditional tea. 🍵',
  'payment':
      'We accept all major credit/debit cards (Visa, Mastercard, Amex) as well as cash on pickup. Payment is captured at time of booking. For cancellations, refunds return to your original payment method within 3-5 business days. 💳',
};

// _getResponse replaced by _GeminiChat

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
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ChatBotPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
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

    final reply = await _gemini.send(msg);
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
              // Header with status bar padding
              _Header(
                onClose: widget.onBack ?? () => Navigator.pop(context),
                fullPage: true,
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
        ),
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

    final reply = await _gemini.send(msg);
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
  const _Header({required this.onClose, this.fullPage = false});

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
                  'App Assistant',
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
                      'Online — AI Travel Guide',
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
          // Close
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
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
                      c.$2,
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
              ),
              child: Text(
                msg.text,
                style: roboto(
                  fontSize: 13,
                  color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                  height: 1.5,
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
                  hintText: 'Chat here...',
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
