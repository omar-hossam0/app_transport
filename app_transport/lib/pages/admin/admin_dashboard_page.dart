import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/favorites_service.dart';
import '../../services/trip_media_service.dart';
import '../../services/trip_service.dart';
import '../auth_widgets.dart';
import '../sign_in_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _navIndex = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripService>().loadTrips();
      context.read<BookingService>().loadAllBookings();
      context.read<AdminService>().loadUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.currentUser == null || auth.currentUser!.isAdmin != true) {
      return _AccessDenied(onBack: () => _toSignIn(context));
    }

    final isCompact = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(isCompact, auth.currentUser!),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(_sectionTitle()),
                  Expanded(
                    child: IndexedStack(
                      index: _navIndex,
                      children: [
                        _buildOrdersTab(),
                        _buildTripsTab(),
                        _buildAdminsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sectionTitle() {
    switch (_navIndex) {
      case 0:
        return 'Orders';
      case 1:
        return 'Trips';
      case 2:
        return 'Admins';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: roboto(fontSize: 22, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage everything in one place',
                  style: roboto(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                const SizedBox(width: 6),
                Text(
                  'Online',
                  style: roboto(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isCompact, UserModel user) {
    final width = isCompact ? 80.0 : 240.0;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: NavigationRail(
        extended: !isCompact,
        selectedIndex: _navIndex,
        onDestinationSelected: (value) {
          setState(() => _navIndex = value);
        },
        backgroundColor: Colors.white,
        groupAlignment: -0.7,
        indicatorColor: kBlue.withValues(alpha: 0.15),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: kBlue,
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(height: 10),
                Text('Admin Panel', style: roboto(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: roboto(fontSize: 10, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: isCompact
              ? IconButton(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                )
              : OutlinedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text('Logout', style: roboto(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: Text('Orders'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.flight_takeoff_rounded),
            label: Text('Trips'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.group_rounded),
            label: Text('Admins'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    final bookingSvc = context.watch<BookingService>();
    final all = bookingSvc.allBookings;
    final filtered = _filterBookings(all);
    final pending = all.where((b) => b.status == BookingStatus.pending).length;
    final accepted = all
        .where((b) => b.status == BookingStatus.accepted)
        .length;
    final completed = all
        .where((b) => b.status == BookingStatus.completed)
        .length;

    if (bookingSvc.isAllLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                title: 'Total Orders',
                value: all.length.toString(),
                icon: Icons.receipt_long_rounded,
                color: kBlue,
              ),
              _StatCard(
                title: 'Pending',
                value: pending.toString(),
                icon: Icons.timelapse_rounded,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Completed',
                value: completed.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Accepted',
                value: accepted.toString(),
                icon: Icons.verified_rounded,
                color: const Color(0xFF4A44AA),
              ),
            ],
          ),
        ),
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
                    onUpdateStatus: (status) =>
                        _updateBookingStatus(filtered[i], status),
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
    final active = trips.where((t) => t.isActive).length;
    final inactive = trips.length - active;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                title: 'Total Trips',
                value: trips.length.toString(),
                icon: Icons.flight_takeoff_rounded,
                color: kBlue,
              ),
              _StatCard(
                title: 'Active',
                value: active.toString(),
                icon: Icons.toggle_on_rounded,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Inactive',
                value: inactive.toString(),
                icon: Icons.toggle_off_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
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
                      onToggleActive: (value) => context
                          .read<TripService>()
                          .setTripActive(trip.id, value),
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
    final adminCount = adminSvc.users.where((user) => user.isAdmin).length;
    final filtered = adminSvc.users.where((u) {
      if (_userQuery.trim().isEmpty) return true;
      final q = _userQuery.toLowerCase();
      return u.email.toLowerCase().contains(q) ||
          u.name.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                title: 'Total Users',
                value: adminSvc.users.length.toString(),
                icon: Icons.people_rounded,
                color: const Color(0xFF1A1A2E),
              ),
              _StatCard(
                title: 'Admins',
                value: adminCount.toString(),
                icon: Icons.security_rounded,
                color: kBlue,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
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
        return bookings
            .where((b) => b.status == BookingStatus.pending)
            .toList();
      case 2:
        return bookings
            .where((b) => b.status == BookingStatus.accepted)
            .toList();
      case 3:
        return bookings
            .where((b) => b.status == BookingStatus.rejected)
            .toList();
      case 4:
        return bookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
      case 5:
        return bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
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

  Future<void> _openTripEditor(BuildContext context, {TripModel? trip}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: roboto(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: roboto(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Wrap(spacing: 8, children: _buildActions(status)),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BookingStatus status) {
    if (status == BookingStatus.pending) {
      return [
        _actionBtn(
          'Accept',
          Colors.green,
          () => onUpdateStatus(BookingStatus.accepted),
        ),
        _actionBtn(
          'Reject',
          Colors.red,
          () => onUpdateStatus(BookingStatus.rejected),
        ),
      ];
    }
    if (status == BookingStatus.accepted) {
      return [
        _actionBtn(
          'Complete',
          kBlue,
          () => onUpdateStatus(BookingStatus.completed),
        ),
        _actionBtn(
          'Cancel',
          Colors.orange,
          () => onUpdateStatus(BookingStatus.cancelled),
        ),
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
    final hasImage = trip.imageUrl.isNotEmpty;
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 84,
                height: 84,
                child: hasImage
                    ? _UrlImage(
                        url: trip.imageUrl,
                        fit: BoxFit.cover,
                        fallback: () => _tripFallback(trip),
                      )
                    : _tripFallback(trip),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: roboto(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${trip.type.name.toUpperCase()}  •  ${trip.durationLabel}',
                    style: roboto(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.priceLabel,
                    style: roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: trip.accentColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: trip.isActive,
                  onChanged: onToggleActive,
                  activeColor: kBlue,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripFallback(TripModel trip) {
    return Container(
      color: trip.accentColor.withValues(alpha: 0.18),
      child: Center(
        child: Icon(
          trip.isFlying ? Icons.flight_rounded : Icons.directions_bus_rounded,
          color: trip.accentColor,
        ),
      ),
    );
  }
}

class _UrlImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget Function() fallback;

  const _UrlImage({
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return fallback();

    if (url.startsWith('data:image')) {
      final commaIndex = url.indexOf(',');
      if (commaIndex <= 0 || commaIndex >= url.length - 1) {
        return fallback();
      }
      try {
        final bytes = base64Decode(url.substring(commaIndex + 1));
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback(),
        );
      } catch (_) {
        return fallback();
      }
    }

    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback(),
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

class _PickedImage {
  final XFile file;
  final Uint8List bytes;

  const _PickedImage({required this.file, required this.bytes});
}

class _TripEditorSheet extends StatefulWidget {
  final TripModel? trip;
  final Future<void> Function(TripModel) onSave;

  const _TripEditorSheet({required this.trip, required this.onSave});

  @override
  State<_TripEditorSheet> createState() => _TripEditorSheetState();
}

class _TripEditorSheetState extends State<_TripEditorSheet> {
  final TripMediaService _media = TripMediaService();
  final ImagePicker _picker = ImagePicker();

  late final String _tripId;
  late final String _initialCoverUrl;
  late TripType _type;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _shortCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _flightCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _routeCtrl;
  late final TextEditingController _mapCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _includedCtrl;
  late final TextEditingController _itineraryCtrl;

  _PickedImage? _coverPick;
  String _coverUrl = '';
  final List<String> _galleryUrls = [];
  final List<_PickedImage> _newGalleryImages = [];

  // Convenience getters
  XFile? get _coverFile => _coverPick?.file;

  bool _isSaving = false;
  double _uploadProgress = 0;
  String _uploadLabel = '';

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _tripId = trip?.id ?? const Uuid().v4();
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
    _priceCtrl = TextEditingController(text: trip?.priceUsd.toString() ?? '0');
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
    _coverUrl = trip?.imageUrl ?? '';
    _initialCoverUrl = _coverUrl;
    _galleryUrls.addAll(trip?.galleryImageUrls ?? const []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _flightCtrl.dispose();
    _priceCtrl.dispose();
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
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: height * 0.94,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(),
            if (_isSaving) _buildUploadStatus(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionCard(
                      title: 'Basics',
                      child: Column(
                        children: [
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
                              if (value != null) {
                                setState(() => _type = value);
                              }
                            },
                            decoration: _fieldDecoration(),
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel('Name'),
                          TextField(
                            controller: _nameCtrl,
                            decoration: _fieldDecoration(),
                          ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Media',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Cover Image'),
                          _buildCoverPicker(),
                          const SizedBox(height: 16),
                          _sectionLabel('Gallery Images'),
                          _buildGalleryPicker(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Pricing & Timing',
                      child: Column(
                        children: [
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
                          _sectionLabel('Accent Color (Hex)'),
                          TextField(
                            controller: _colorCtrl,
                            decoration: _fieldDecoration(hint: 'e.g. FF187BCD'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Routing',
                      child: Column(
                        children: [
                          _sectionLabel('Route Label'),
                          TextField(
                            controller: _routeCtrl,
                            decoration: _fieldDecoration(
                              hint: 'Airport -> ...',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel('Map Hint'),
                          TextField(
                            controller: _mapCtrl,
                            decoration: _fieldDecoration(
                              hint: 'Route outline for map',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel('Location Label'),
                          TextField(
                            controller: _locationCtrl,
                            decoration: _fieldDecoration(
                              hint: 'Cairo International Airport',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Included & Itinerary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Included (comma separated)'),
                          TextField(
                            controller: _includedCtrl,
                            decoration: _fieldDecoration(
                              hint: 'Transfer, Guide, Tickets',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel('Itinerary (one stop per line)'),
                          TextField(
                            controller: _itineraryCtrl,
                            decoration: _fieldDecoration(
                              hint:
                                  'Title|Subtitle|Duration|iconName|colorHex|imageUrl',
                            ),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Icons: ${TripIconHelper.iconNames().join(', ')}',
                            style: roboto(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                        ),
                        child: Text('Save Trip', style: roboto()),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.trip == null ? 'Create Trip' : 'Edit Trip',
              style: roboto(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            _type == TripType.flying ? 'Flying' : 'Transit',
            style: roboto(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildUploadStatus() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _uploadLabel,
            style: roboto(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
            backgroundColor: Colors.grey.shade200,
            color: kBlue,
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: roboto(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCoverPicker() {
    final hasFile = _coverPick != null;
    final hasUrl = _coverUrl.isNotEmpty;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 120,
            height: 86,
            child: hasFile
                ? _buildPickedImage(
                    _coverFile!,
                    fallback: _coverFallback,
                    bytes: _coverPick!.bytes,
                  )
                : hasUrl
                ? _UrlImage(
                    url: _coverUrl,
                    fit: BoxFit.cover,
                    fallback: _coverFallback,
                  )
                : _coverFallback(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasFile || hasUrl ? 'Cover selected' : 'No cover selected',
                style: roboto(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickCover,
                    icon: const Icon(Icons.photo_rounded, size: 16),
                    label: Text('Select', style: roboto(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: (hasFile || hasUrl) ? _removeCover : null,
                    child: Text('Remove', style: roboto(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryPicker() {
    final tiles = <Widget>[];
    for (final url in _galleryUrls) {
      tiles.add(
        _buildGalleryTile(
          child: _UrlImage(
            url: url,
            fit: BoxFit.cover,
            fallback: _galleryFallback,
          ),
          onRemove: () => _removeGalleryUrl(url),
        ),
      );
    }
    for (final pick in _newGalleryImages) {
      tiles.add(
        _buildGalleryTile(
          child: _buildPickedImage(
            pick.file,
            fallback: _galleryFallback,
            bytes: pick.bytes,
          ),
          onRemove: () => _removeGalleryPick(pick),
        ),
      );
    }
    tiles.add(_buildGalleryAddTile());

    return Wrap(spacing: 10, runSpacing: 10, children: tiles);
  }

  Widget _buildGalleryTile({
    required Widget child,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 84, height: 84, child: child),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryAddTile() {
    return InkWell(
      onTap: _pickGallery,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_rounded, size: 22),
            const SizedBox(height: 4),
            Text('Add', style: roboto(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _coverFallback() {
    return Container(
      color: const Color(0xFFEFF2F6),
      child: const Icon(Icons.photo_rounded, color: Colors.grey),
    );
  }

  Widget _galleryFallback() {
    return Container(
      color: const Color(0xFFEFF2F6),
      child: const Icon(Icons.photo_rounded, color: Colors.grey),
    );
  }

  Widget _buildPickedImage(
    XFile file, {
    required Widget Function() fallback,
    Uint8List? bytes,
  }) {
    // If bytes are already loaded, use them directly — works on both web and mobile
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          if (snapshot.hasError) {
            return fallback();
          }
          return Container(
            color: const Color(0xFFEFF2F6),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    return Image.memory(
      bytes ?? Uint8List(0),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  Future<void> _pickCover() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _coverPick = _PickedImage(file: picked, bytes: bytes);
    });
  }

  void _removeCover() {
    setState(() {
      _coverPick = null;
      _coverUrl = '';
    });
  }

  Future<void> _pickGallery() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    final picks = <_PickedImage>[];
    for (final file in picked) {
      final bytes = await file.readAsBytes();
      picks.add(_PickedImage(file: file, bytes: bytes));
    }
    setState(() {
      _newGalleryImages.addAll(picks);
    });
  }

  Future<void> _removeGalleryUrl(String url) async {
    setState(() {
      _galleryUrls.remove(url);
    });
    await _media.deleteByUrl(url);
  }

  void _removeGalleryPick(_PickedImage pick) {
    setState(() {
      _newGalleryImages.remove(pick);
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _uploadProgress = 0;
      _uploadLabel = 'Preparing uploads...';
    });

    try {
      var hadMediaUploadFailure = false;
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

      var coverUrl = _coverUrl;
      if (_coverFile != null) {
        try {
          final task = _media.uploadCover(
            tripId: _tripId,
            file: _coverFile!,
            bytes: _coverPick?.bytes,
          );
          coverUrl = await _uploadWithProgress(task, 'Uploading cover');
        } catch (e) {
          final canUseInlineImage =
              kIsWeb &&
              _coverPick?.bytes != null &&
              _coverPick!.bytes.isNotEmpty;
          if (!canUseInlineImage) rethrow;
          hadMediaUploadFailure = true;
          coverUrl = _asDataUrl(_coverPick!.bytes, _coverPick!.file.name);
          debugPrint(
            '[TripEditor] Cover upload failed, using inline image data: $e',
          );
        }
        if (_initialCoverUrl.isNotEmpty && _initialCoverUrl != coverUrl) {
          await _media.deleteByUrl(_initialCoverUrl);
        }
      } else if (_coverUrl.isEmpty && _initialCoverUrl.isNotEmpty) {
        await _media.deleteByUrl(_initialCoverUrl);
      }

      final galleryUrls = List<String>.from(_galleryUrls);
      for (var i = 0; i < _newGalleryImages.length; i++) {
        try {
          final pick = _newGalleryImages[i];
          try {
            final task = _media.uploadGallery(
              tripId: _tripId,
              file: pick.file,
              bytes: pick.bytes,
            );
            final url = await _uploadWithProgress(
              task,
              'Uploading gallery ${i + 1}/${_newGalleryImages.length}',
            );
            galleryUrls.add(url);
          } catch (e) {
            final canUseInlineImage = kIsWeb && pick.bytes.isNotEmpty;
            if (!canUseInlineImage) rethrow;
            hadMediaUploadFailure = true;
            galleryUrls.add(_asDataUrl(pick.bytes, pick.file.name));
            debugPrint(
              '[TripEditor] Gallery upload ${i + 1} failed, using inline image data: $e',
            );
          }
        } catch (e) {
          hadMediaUploadFailure = true;
          debugPrint(
            '[TripEditor] Gallery upload ${i + 1} failed, continuing save: $e',
          );
        }
      }

      final trip = TripModel(
        id: _tripId,
        type: _type,
        name: _nameCtrl.text.trim(),
        shortDescription: _shortCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        durationMinutes: duration,
        flightMinutes: flight,
        priceUsd: price,
        imageUrl: coverUrl,
        galleryImageUrls: galleryUrls,
        accentColorValue: color,
        routeLabel: _routeCtrl.text.trim(),
        mapHint: _mapCtrl.text.trim(),
        locationLabel: _locationCtrl.text.trim(),
        included: included,
        itinerary: itinerary,
        isActive: widget.trip?.isActive ?? true,
        createdAt: widget.trip?.createdAt,
      );

      await widget.onSave(trip);
      if (!mounted) return;

      if (hadMediaUploadFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trip saved, but one or more images failed to upload.',
              style: roboto(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      final msg = e.toString();
      debugPrint('[TripEditor] ❌ Save FAILED!');
      debugPrint('[TripEditor] Error Type: ${e.runtimeType}');
      debugPrint('[TripEditor] Error Message: $msg');

      String userMessage;
      if (msg.contains('PERMISSION_DENIED') ||
          msg.contains('permission-denied') ||
          msg.contains('Permission denied')) {
        userMessage =
            '❌ خطأ صلاحيات Firebase!\n\n'
            'تحقق من:\n'
            '✓ قواعس Firebase Database\n'
            '✓ قواعس Firebase Storage\n'
            '✓ هل حسابك Admin؟';
        debugPrint('[TripEditor] → Fix: Update Firebase Rules');
      } else if (msg.contains('CORS') || msg.contains('preflight')) {
        userMessage =
            '❌ خطأ CORS\n\n'
            'الحل: طبّق cors.json على Firebase';
        debugPrint('[TripEditor] → Fix: Run gsutil cors set');
      } else if (msg.contains('timeout') || msg.contains('Timeout')) {
        userMessage =
            '❌ انقطاع الاتصال\n\n'
            'تحقق من:\n'
            '✓ الإنترنت مفعّل؟\n'
            '✓ Firebase accessible?';
      } else {
        userMessage = '❌ خطأ: ${msg.split('\n').first}';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage, style: roboto(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _uploadProgress = 0;
          _uploadLabel = '';
        });
      }
    }
  }

  Future<String> _uploadWithProgress(
    UploadTask task,
    String label, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    if (mounted) {
      setState(() {
        _uploadLabel = label;
        _uploadProgress = 0;
      });
    }

    final sub = task.snapshotEvents.listen(
      (snapshot) {
        final total = snapshot.totalBytes;
        if (total <= 0 || !mounted) return;
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / total;
        });
      },
      onError: (_) {
        // Task completion is handled by await task; ignore stream noise here.
      },
      cancelOnError: false,
    );

    try {
      final result = await task.timeout(
        timeout,
        onTimeout: () async {
          await task.cancel();
          throw TimeoutException('Upload timed out');
        },
      );
      return result.ref.getDownloadURL();
    } finally {
      await sub.cancel();
    }
  }

  String _asDataUrl(Uint8List bytes, String fileName) {
    final lower = fileName.toLowerCase();
    final mime = lower.endsWith('.png')
        ? 'image/png'
        : lower.endsWith('.webp')
        ? 'image/webp'
        : lower.endsWith('.gif')
        ? 'image/gif'
        : 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
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
                child: Text(
                  'Back to Sign In',
                  style: roboto(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
