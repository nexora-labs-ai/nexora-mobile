import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/components/error_view.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';
import '../../../activity/presentation/widgets/activity_card.dart';
import '../../../expenses/presentation/pages/expense_list_page.dart';
import '../../../itinerary/presentation/pages/itinerary_page.dart';
import '../../../settlements/presentation/screens/settlements_screen.dart';
import '../../domain/entities/group_entity.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';
import 'invite_member_page.dart';
import '../../../../shared/widgets/lazy_indexed_stack.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupLeft) {
          context.go('/groups');
        } else if (state is GroupFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: _GroupDetailView(groupId: groupId),
    );
  }
}

class _GroupDetailView extends StatefulWidget {
  const _GroupDetailView({required this.groupId});

  final String groupId;

  @override
  State<_GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<_GroupDetailView> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupState>(
      buildWhen: (previous, current) {
        return current is GroupDetailLoaded || 
               current is GroupFailureState || 
               (current is GroupLoading && previous is! GroupDetailLoaded);
      },
      builder: (context, state) {
        return switch (state) {
          GroupInitial() || GroupLoading() => const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary))),
          GroupDetailLoaded(:final group) => Scaffold(
              backgroundColor: const Color(0xFFF2F5EA),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon:
                      const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  group.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () =>
                          context.push('/groups/${widget.groupId}/settings'),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: group.avatarUrl != null
                            ? NetworkImage(group.avatarUrl!)
                            : null,
                        backgroundColor: AppColors.surfaceContainer,
                        child: group.avatarUrl == null
                            ? const Icon(Icons.groups,
                                color: AppColors.onSurfaceVariant, size: 20)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: _currentTabIndex == 2
                  ? FloatingActionButton(
                      onPressed: () => context
                          .push('/groups/${widget.groupId}/expenses/create'),
                      backgroundColor: const Color(0xFF9FE870),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.add,
                          color: Colors.black87, size: 28),
                    )
                  : null,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _GroupTabs(
                    groupId: widget.groupId,
                    currentIndex: _currentTabIndex,
                    onTabSelected: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LazyIndexedStack(
                      index: _currentTabIndex,
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _GroupFundCard(group: group),
                              const SizedBox(height: 32),
                              _RecentActivitySection(groupId: widget.groupId),
                            ],
                          ),
                        ),
                        ItineraryPage(groupId: widget.groupId, isTab: true),
                        ExpenseListPage(groupId: widget.groupId, isTab: true),
                        SettlementsScreen(groupId: widget.groupId, isTab: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          GroupFailureState(:final message) => Scaffold(
              body: ErrorView(
                message: message,
                onRetry: () =>
                    context.read<GroupCubit>().loadGroupDetail(widget.groupId),
              ),
            ),
          _ => const Scaffold(body: SizedBox.shrink()),
        };
      },
    );
  }
}

class _GroupTabs extends StatelessWidget {
  const _GroupTabs({
    required this.groupId,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final String groupId;
  final int currentIndex;
  final Function(int) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabItem(
              title: 'Overview',
              isActive: currentIndex == 0,
              onTap: () => onTabSelected(0)),
          _TabItem(
              title: 'Itinerary',
              isActive: currentIndex == 1,
              onTap: () => onTabSelected(1)),
          _TabItem(
              title: 'Expenses',
              isActive: currentIndex == 2,
              onTap: () => onTabSelected(2)),
          _TabItem(
              title: 'Settle Up',
              isActive: currentIndex == 3,
              onTap: () => onTabSelected(3)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF9FE870) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black87 : AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupFundCard extends StatelessWidget {
  const _GroupFundCard({required this.group});

  final GroupEntity group;

  @override
  Widget build(BuildContext context) {
    final balanceStr = group.fund != null
        ? minorUnitsToDouble(group.fund!.balance).toStringAsFixed(2)
        : '0.00';
    final currency = group.currency == 'USD' ? '\$' : group.currency;

    final totalSpentStr = group.totalSpent != null
        ? group.totalSpent!.toStringAsFixed(2)
        : '0.00';

    final budget = group.budgetGoal ?? 0.0;
    final spent = group.totalSpent ?? 0.0;
    final double progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
        onTap: () => context.push('/groups/${group.id}/fund'),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Fund Balance',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currency$balanceStr',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Spent',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$currency$totalSpentStr',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF5F5F5),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF9FE870)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (_) => BlocProvider.value(
                            value: context.read<GroupCubit>(),
                            child: InviteMemberPage(groupId: group.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 20),
                      label: const Text('Invite'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/groups/${group.id}/chat'),
                      icon: const Icon(Icons.chat_bubble_outline, size: 20),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Currently there's no group-specific activity page,
                  // We navigate to the general activity tab for now or stay on the page.
                },
                child: Text(
                  'View all',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF6B8E23),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) {
            if (state is ActivityLoading) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ));
            }

            if (state is ActivityLoaded) {
              if (state.activities.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No recent activity in this group.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                );
              }

              // Show up to 3 recent activities
              final activities = state.activities.take(3).toList();
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: activities.map((activity) {
                    final isLast = activity == activities.last;
                    return Column(
                      children: [
                        ActivityCard(activity: activity),
                        if (!isLast)
                          const Divider(
                              height: 1,
                              color: Color(0xFFF5F5F5),
                              indent: 16,
                              endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
