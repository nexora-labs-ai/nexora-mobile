import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..loadNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8F3), // Off-white/light-green background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading || state is NotificationsInitial) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2F6C00)));
          }

          if (state is NotificationsFailure) {
            return Center(child: Text(state.message));
          }

          if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            final unread = notifications
                .where((n) => (n['isRead'] as bool? ?? false) == false)
                .toList();
            final read = notifications
                .where((n) => (n['isRead'] as bool? ?? false) == true)
                .toList();

            return ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                _buildHeader(context),
                if (unread.isNotEmpty) ...[
                  _buildSectionTitle('NEW', hasUnread: true),
                  ...unread.map((n) => _buildNotificationItem(
                      context, n as Map<String, dynamic>)),
                ],
                if (read.isNotEmpty) ...[
                  _buildSectionTitle('EARLIER', hasUnread: false),
                  ...read.map((n) => _buildNotificationItem(
                      context, n as Map<String, dynamic>)),
                ],
                if (unread.isEmpty && read.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        'No notifications yet',
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay updated on your shared\nworld',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDCF2C7), // Light green bg
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            icon:
                const Icon(Icons.done_all, size: 16, color: Color(0xFF2F6C00)),
            label: Text(
              'Mark all read',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F6C00),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool hasUnread = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF757575),
            ),
          ),
          if (hasUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF2F6C00),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMockItem({
    required Widget icon,
    required Color iconBgColor,
    required Widget titleWidget,
    String? amount,
    required String time,
    required bool isUnread,
    Widget? actions,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(0), // Rectangular like the screenshot
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16), // Rounded square
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleWidget),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F6C00),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (amount != null) ...[
                      Text(
                        amount,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                  ],
                ),
                if (actions != null) ...[
                  const SizedBox(height: 16),
                  actions,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, Map<String, dynamic> notification) {
    final type = notification['type'] as String? ?? '';
    final title = notification['title'] as String? ?? '';
    final body = notification['body'] as String? ?? '';
    final isRead = notification['isRead'] as bool? ?? false;
    final createdAt = notification['createdAt'] as String?;
    final time = _formatTime(createdAt);
    final data = notification['data'] as Map<String, dynamic>? ?? {};

    Widget icon =
        const Icon(Icons.notifications_outlined, color: Color(0xFF4A4A4A));
    Color iconBgColor = const Color(0xFFE0E0E0);
    Widget? actions;

    if (type == 'EXPENSE_CREATED' || type == 'EXPENSE_UPDATED') {
      icon = const Icon(Icons.restaurant, color: Color(0xFF2F6C00));
      iconBgColor = const Color(0xFFE8F5E9);
    } else if (type == 'SETTLEMENT_REQUESTED') {
      icon = const Icon(Icons.payments_outlined, color: Color(0xFF4A4A4A));
      iconBgColor = const Color(0xFFE0E0E0);
    } else if (type == 'GROUP_INVITE') {
      icon =
          const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF4A4A4A));
      iconBgColor = const Color(0xFFE0E0E0);

      final token = data['token'] as String?;
      final status = data['status'] as String?;
      final id = notification['id'] as String;

      if (token != null && status == null) {
        actions = Row(
          children: [
            ElevatedButton(
              onPressed: () => context
                  .read<NotificationsCubit>()
                  .acceptInvitation(id, token),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6C00),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: Text('Accept',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => context
                  .read<NotificationsCubit>()
                  .rejectInvitation(id, token),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                foregroundColor: const Color(0xFF2F6C00),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              child: Text('Decline',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A4A4A))),
            ),
          ],
        );
      }
    } else if (type == 'SYSTEM') {
      icon = const Icon(Icons.notifications_active_outlined,
          color: Color(0xFFC62828));
      iconBgColor = const Color(0xFFFFEBEE);
    }

    Widget titleWidget = Text(
      body.isNotEmpty ? body : title,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: const Color(0xFF1E1E1E),
        height: 1.4,
      ),
    );

    return _buildMockItem(
      icon: icon,
      iconBgColor: iconBgColor,
      titleWidget: titleWidget,
      time: time,
      isUnread: !isRead,
      actions: actions,
    );
  }

  String _formatTime(String? createdAtString) {
    if (createdAtString == null) return '';
    final dateTime = DateTime.tryParse(createdAtString)?.toLocal();
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24 && now.day == dateTime.day) {
      if (difference.inMinutes < 60) {
        if (difference.inMinutes == 0) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}
