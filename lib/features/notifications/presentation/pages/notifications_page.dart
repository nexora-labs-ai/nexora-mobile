import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..loadNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            Builder(
              builder: (context) => TextButton(
                onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
                child: const Text('Mark all read'),
              ),
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationsFailure) {
              return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
            }

            if (state is NotificationsLoaded) {
              final notifications = state.notifications;
              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.textDisabled),
                      const SizedBox(height: 16),
                      Text('No notifications yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index] as Map<String, dynamic>;
                  final isRead = notif['isRead'] as bool? ?? false;
                  final type = notif['type'] as String?;
                  final payload = notif['data'] as Map<String, dynamic>?;

                  return ListTile(
                    tileColor: isRead ? null : AppColors.primary.withOpacity(0.05),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                    title: Text(notif['title'] as String? ?? ''),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif['body'] as String? ?? ''),
                        if (type == 'GROUP_INVITE' && payload != null && payload['token'] != null)
                          if (payload['status'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                payload['status'] == 'ACCEPTED' ? 'Accepted' : 'Rejected',
                                style: TextStyle(
                                  color: payload['status'] == 'ACCEPTED' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<NotificationsCubit>().acceptInvitation(
                                            notif['id'] as String,
                                            payload['token'] as String,
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                    child: const Text('Accept', style: TextStyle(color: Colors.white)),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      context.read<NotificationsCubit>().rejectInvitation(
                                            notif['id'] as String,
                                            payload['token'] as String,
                                          );
                                    },
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                    onTap: () {
                      if (!isRead) {
                        context.read<NotificationsCubit>().markAsRead(notif['id'] as String);
                      }
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
