import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/favorites_service.dart';
import '../../services/trip_service.dart';
import '../auth_widgets.dart';
import '../sign_in_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _orderFilterIndex = 0;
  final _orderFilters = const [
    'All',
    'Pending',
    'Accepted',
    'Rejected',
    'Completed',
    'Cancelled',
  ];
  String _userQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripService>().loadTrips();
      context.read<BookingService>().loadAllBookings();
      context.read<AdminService>().loadUsers();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.currentUser == null || auth.currentUser!.isAdmin != true) {
      return _AccessDenied(onBack: () => _toSignIn(context));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Admin Dashboard', style: roboto(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _handleLogout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: kBlue,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: kBlue,
          tabs: const [
            Tab(text: 'Orders'),
            Tab(text: 'Trips'),
            Tab(text: 'Admins'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildOrdersTab(),
          _buildTripsTab(),
          _buildAdminsTab(),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    final bookingSvc = context.watch<BookingService>();
    final all = bookingSvc.allBookings;
    final filtered = _filterBookings(all);

    if (bookingSvc.isAllLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        _buildOrderFilters(),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No orders in this filter',
                    style: roboto(color: Colors.grey.shade500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemBuilder: (context, i) => _OrderCard(
                    booking: filtered[i],
                    onUpdateStatus: (status) => _updateBookingStatus(
                      filtered[i],
                      status,
                    ),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filtered.length,
                ),
        ),
      ],
    );
  }

  Widget _buildTripsTab() {
    final tripSvc = context.watch<TripService>();
    final trips = tripSvc.trips;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Manage trip catalog',
                  style: roboto(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openTripEditor(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Add Trip', style: roboto(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tripSvc.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemBuilder: (context, i) {
                    final trip = trips[i];
                    return _TripCard(
                      trip: trip,
                      onEdit: () => _openTripEditor(context, trip: trip),
                      onDelete: () => _confirmDeleteTrip(context, trip),
                      onToggleActive: (value) =>
                          context.read<TripService>().setTripActive(
                                trip.id,
                                value,
                              ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: trips.length,
                ),
        ),
      ],
    );
  }

  Widget _buildAdminsTab() {
    final adminSvc = context.watch<AdminService>();
    final filtered = adminSvc.users.where((u) {
      if (_userQuery.trim().isEmpty) return true;
      final q = _userQuery.toLowerCase();
      return u.email.toLowerCase().contains(q) ||
          u.name.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _userQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ),
        Expanded(
          child: adminSvc.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemBuilder: (context, i) {
                    final user = filtered[i];
                    return _AdminUserTile(
                      user: user,
                      onToggle: (value) => context
                          .read<AdminService>()
                          .setAdminRole(uid: user.uid, isAdmin: value),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: filtered.length,
                ),
        ),
      ],
    );
  }

  Widget _buildOrderFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final active = _orderFilterIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _orderFilterIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? kBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? kBlue : Colors.grey.shade200,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: kBlue.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                _orderFilters[i],
                style: roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _orderFilters.length,
      ),
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    switch (_orderFilterIndex) {
      case 1:
        return bookings.where((b) => b.status == BookingStatus.pending).toList();
      case 2:
        return bookings.where((b) => b.status == BookingStatus.accepted).toList();
      case 3:
        return bookings.where((b) => b.status == BookingStatus.rejected).toList();
      case 4:
        return bookings.where((b) => b.status == BookingStatus.completed).toList();
      case 5:
        return bookings.where((b) => b.status == BookingStatus.cancelled).toList();
      default:
        return bookings;
    }
  }

  Future<void> _updateBookingStatus(
    Booking booking,
    BookingStatus status,
  ) async {
    await context.read<BookingService>().updateStatus(
          booking.userId,
          booking.id,
          status,
        );
  }

  Future<void> _openTripEditor(
    BuildContext context, {
    TripModel? trip,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TripEditorSheet(
        trip: trip,
        onSave: (updated) async {
          final svc = context.read<TripService>();
          if (trip == null) {
            await svc.createTrip(updated);
          } else {
            await svc.updateTrip(updated);
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteTrip(BuildContext context, TripModel trip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Trip?', style: roboto(fontWeight: FontWeight.w700)),
        content: Text(
          'This will remove the trip from the catalog for all users.',
          style: roboto(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: roboto()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: roboto(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await context.read<TripService>().deleteTrip(trip.id);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final auth = context.read<AuthService>();
    await auth.signOut();
    context.read<BookingService>().clearBookings();
    context.read<FavoritesService>().clearFavorites();
    if (!mounted) return;
    _toSignIn(context);
  }

  void _toSignIn(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (_) => false,
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Booking booking;
  final void Function(BookingStatus status) onUpdateStatus;
  const _OrderCard({required this.booking, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.tripName,
                  style: roboto(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.userEmail.isNotEmpty ? booking.userEmail : 'Unknown user',
            style: roboto(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            'Date: ${booking.date.toLocal().toString().split(' ')[0]}',
            style: roboto(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _buildActions(status),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BookingStatus status) {
    if (status == BookingStatus.pending) {
      return [
        _actionBtn('Accept', Colors.green, () => onUpdateStatus(BookingStatus.accepted)),
        _actionBtn('Reject', Colors.red, () => onUpdateStatus(BookingStatus.rejected)),
      ];
    }
    if (status == BookingStatus.accepted) {
      return [
        _actionBtn('Complete', kBlue, () => onUpdateStatus(BookingStatus.completed)),
        _actionBtn('Cancel', Colors.orange, () => onUpdateStatus(BookingStatus.cancelled)),
      ];
    }
    return [];
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: roboto(fontSize: 12, color: color)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(status),
        style: roboto(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.completed:
        return kBlue;
      case BookingStatus.cancelled:
        return Colors.grey;
    }
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  const _TripCard({
    required this.trip,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        title: Text(
          trip.name,
          style: roboto(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${trip.type.name.toUpperCase()}  •  ${trip.durationLabel}  •  ${trip.priceLabel}',
          style: roboto(fontSize: 12, color: Colors.grey.shade600),
        ),
        leading: CircleAvatar(
          backgroundColor: trip.accentColor.withValues(alpha: 0.15),
          child: Icon(
            trip.isFlying ? Icons.flight_rounded : Icons.directions_bus_rounded,
            color: trip.accentColor,
          ),
        ),
        trailing: Wrap(
          spacing: 6,
          children: [
            Switch(
              value: trip.isActive,
              onChanged: onToggleActive,
              activeColor: kBlue,
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUserTile extends StatelessWidget {
  final UserModel user;
  final ValueChanged<bool> onToggle;
  const _AdminUserTile({required this.user, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        title: Text(user.name, style: roboto(fontWeight: FontWeight.w700)),
        subtitle: Text(user.email, style: roboto(fontSize: 12)),
        trailing: Switch(
          value: user.isAdmin,
          activeColor: kBlue,
          onChanged: onToggle,
        ),
      ),
    );
  }
}

class _TripEditorSheet extends StatefulWidget {
  final TripModel? trip;
  final ValueChanged<TripModel> onSave;

  const _TripEditorSheet({required this.trip, required this.onSave});

  @override
  State<_TripEditorSheet> createState() => _TripEditorSheetState();
}

class _TripEditorSheetState extends State<_TripEditorSheet> {
  late TripType _type;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _shortCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _flightCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _routeCtrl;
  late final TextEditingController _mapCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _includedCtrl;
  late final TextEditingController _itineraryCtrl;

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _type = trip?.type ?? TripType.transit;
    _nameCtrl = TextEditingController(text: trip?.name ?? '');
    _shortCtrl = TextEditingController(text: trip?.shortDescription ?? '');
    _descCtrl = TextEditingController(text: trip?.description ?? '');
    _durationCtrl = TextEditingController(
      text: trip?.durationMinutes.toString() ?? '0',
    );
    _flightCtrl = TextEditingController(
      text: trip?.flightMinutes.toString() ?? '0',
    );
    _priceCtrl = TextEditingController(
      text: trip?.priceUsd.toString() ?? '0',
    );
    _imageCtrl = TextEditingController(text: trip?.imageUrl ?? '');
    _colorCtrl = TextEditingController(
      text: _toHex(trip?.accentColorValue ?? 0xFF187BCD),
    );
    _routeCtrl = TextEditingController(text: trip?.routeLabel ?? '');
    _mapCtrl = TextEditingController(text: trip?.mapHint ?? '');
    _locationCtrl = TextEditingController(
      text: trip?.locationLabel ?? 'Cairo International Airport',
    );
    _includedCtrl = TextEditingController(
      text: (trip?.included ?? []).join(', '),
    );
    _itineraryCtrl = TextEditingController(
      text: _serializeStops(trip?.itinerary ?? []),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _flightCtrl.dispose();
    _priceCtrl.dispose();
    _imageCtrl.dispose();
    _colorCtrl.dispose();
    _routeCtrl.dispose();
    _mapCtrl.dispose();
    _locationCtrl.dispose();
    _includedCtrl.dispose();
    _itineraryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.trip == null ? 'Add Trip' : 'Edit Trip',
                style: roboto(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _sectionLabel('Trip Type'),
              DropdownButtonFormField<TripType>(
                value: _type,
                items: TripType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
                decoration: _fieldDecoration(),
              ),
              const SizedBox(height: 12),
              _sectionLabel('Name'),
              TextField(controller: _nameCtrl, decoration: _fieldDecoration()),
              const SizedBox(height: 12),
              _sectionLabel('Short Description'),
              TextField(
                controller: _shortCtrl,
                decoration: _fieldDecoration(),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Full Description'),
              TextField(
                controller: _descCtrl,
                decoration: _fieldDecoration(),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Duration Minutes'),
              TextField(
                controller: _durationCtrl,
                decoration: _fieldDecoration(hint: 'e.g. 120'),
                keyboardType: TextInputType.number,
              ),
              if (_type == TripType.flying) ...[
                const SizedBox(height: 12),
                _sectionLabel('Flight Minutes'),
                TextField(
                  controller: _flightCtrl,
                  decoration: _fieldDecoration(hint: 'e.g. 20'),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 12),
              _sectionLabel('Price (USD)'),
              TextField(
                controller: _priceCtrl,
                decoration: _fieldDecoration(hint: 'e.g. 150'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Image URL'),
              TextField(controller: _imageCtrl, decoration: _fieldDecoration()),
              const SizedBox(height: 12),
              _sectionLabel('Accent Color (Hex)'),
              TextField(
                controller: _colorCtrl,
                decoration: _fieldDecoration(hint: 'e.g. FF187BCD'),
              ),
              const SizedBox(height: 12),
              _sectionLabel('Route Label'),
              TextField(
                controller: _routeCtrl,
                decoration: _fieldDecoration(hint: 'Airport -> ...'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Map Hint'),
              TextField(
                controller: _mapCtrl,
                decoration: _fieldDecoration(hint: 'Route outline for map'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Location Label'),
              TextField(
                controller: _locationCtrl,
                decoration: _fieldDecoration(hint: 'Cairo International Airport'),
              ),
              const SizedBox(height: 12),
              _sectionLabel('Included (comma separated)'),
              TextField(
                controller: _includedCtrl,
                decoration: _fieldDecoration(hint: 'Transfer, Guide, Tickets'),
              ),
              const SizedBox(height: 12),
              _sectionLabel('Itinerary (one stop per line)'),
              TextField(
                controller: _itineraryCtrl,
                decoration: _fieldDecoration(
                  hint: 'Title|Subtitle|Duration|iconName|colorHex|imageUrl',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 6),
              Text(
                'Icons: ${TripIconHelper.iconNames().join(', ')}',
                style: roboto(fontSize: 10, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue),
                  child: Text('Save Trip', style: roboto(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final duration = int.tryParse(_durationCtrl.text.trim()) ?? 0;
    final flight = int.tryParse(_flightCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final color = _parseColor(_colorCtrl.text.trim(), 0xFF187BCD);
    final included = _includedCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final itinerary = _parseStops(_itineraryCtrl.text.trim());

    final trip = TripModel(
      id: widget.trip?.id ?? '',
      type: _type,
      name: _nameCtrl.text.trim(),
      shortDescription: _shortCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      durationMinutes: duration,
      flightMinutes: flight,
      priceUsd: price,
      imageUrl: _imageCtrl.text.trim(),
      accentColorValue: color,
      routeLabel: _routeCtrl.text.trim(),
      mapHint: _mapCtrl.text.trim(),
      locationLabel: _locationCtrl.text.trim(),
      included: included,
      itinerary: itinerary,
      isActive: widget.trip?.isActive ?? true,
      createdAt: widget.trip?.createdAt,
    );

    widget.onSave(trip);
    Navigator.of(context).pop();
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: roboto(fontWeight: FontWeight.w600)),
    );
  }

  int _parseColor(String raw, int fallback) {
    var hex = raw.replaceAll('#', '').trim();
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return fallback;
    return int.tryParse(hex, radix: 16) ?? fallback;
  }

  String _toHex(int value) {
    return value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  String _serializeStops(List<TripStop> stops) {
    return stops
        .map(
          (s) =>
              '${s.title}|${s.subtitle}|${s.duration}|${s.iconName}|${_toHex(s.colorValue)}|${s.imageUrl}',
        )
        .join('\n');
  }

  List<TripStop> _parseStops(String raw) {
    if (raw.isEmpty) return [];
    final lines = raw.split('\n');
    final stops = <TripStop>[];
    for (final line in lines) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      if (parts.isEmpty || parts.first.isEmpty) continue;
      stops.add(
        TripStop(
          title: parts[0],
          subtitle: parts.length > 1 ? parts[1] : '',
          duration: parts.length > 2 ? parts[2] : '',
          iconName: parts.length > 3 ? parts[3] : 'place',
          colorValue: _parseColor(parts.length > 4 ? parts[4] : '', 0xFF187BCD),
          imageUrl: parts.length > 5 ? parts[5] : '',
        ),
      );
    }
    return stops;
  }
}

class _AccessDenied extends StatelessWidget {
  final VoidCallback onBack;
  const _AccessDenied({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 48, color: kBlue),
              const SizedBox(height: 12),
              Text(
                'Admin access required',
                style: roboto(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Please sign in with an admin account.',
                style: roboto(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(backgroundColor: kBlue),
                child: Text('Back to Sign In', style: roboto(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
