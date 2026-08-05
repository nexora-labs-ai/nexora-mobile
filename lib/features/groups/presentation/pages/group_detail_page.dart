import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../shared/components/error_view.dart';
import '../../../expenses/presentation/pages/expense_list_page.dart';
import '../../../itinerary/presentation/pages/itinerary_page.dart';
import '../../../settlements/presentation/screens/settlements_screen.dart';
import '../../domain/entities/group_entity.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

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

class _GroupDetailViewState extends State<_GroupDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
              backgroundColor: const Color(0xFFF1F3ED),
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildSliverAppBar(group),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xFF2F6C00),
                          unselectedLabelColor: const Color(0xFF757575),
                          labelStyle: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.bold),
                          unselectedLabelStyle: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          indicatorColor: const Color(0xFF2F6C00),
                          indicatorWeight: 3,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Itinerary'),
                            Tab(text: 'Expenses'),
                            Tab(text: 'Settle Up'),
                            Tab(text: 'Chat'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(group),
                    ItineraryPage(groupId: widget.groupId, isTab: true),
                    ExpenseListPage(groupId: widget.groupId, isTab: true),
                    SettlementsScreen(groupId: widget.groupId, isTab: true),
                    const Center(child: Text('AI Chat Coming Soon')),
                  ],
                ),
              ),
            ),
          GroupFailureState() => ErrorView(
              message: 'Failed to load group details',
              onRetry: () =>
                  context.read<GroupCubit>().loadGroupDetail(widget.groupId),
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildSliverAppBar(GroupEntity group) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: const Color(0xFF2F6C00),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
          ),
          const SizedBox(width: 8),
          Text(
            'Nexora',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (group.avatarUrl != null && group.avatarUrl!.isNotEmpty)
              Image.network(
                group.avatarUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.3),
                colorBlendMode: BlendMode.darken,
              )
            else
              Container(color: const Color(0xFF2F6C00)),
            Positioned(
              left: 24,
              bottom: 40,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push('/groups/${group.id}/members');
                        },
                        child: Row(
                          children: _buildDynamicMembers(group.memberCount),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/groups/${group.id}/invite');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9CCC65),
                          foregroundColor: const Color(0xFF1E1E1E),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Invite Members',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicMembers(int memberCount) {
    if (memberCount <= 0) return [];

    final List<Widget> avatars = [];
    final colors = [
      const Color(0xFFE0E0E0),
      const Color(0xFFCFD8DC),
      const Color(0xFFFFCC80),
      const Color(0xFFB39DDB),
    ];

    int displayCount = memberCount > 3 ? 3 : memberCount;

    for (int i = 0; i < displayCount; i++) {
      avatars.add(
        Transform.translate(
          offset: Offset(i * -12.0, 0),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors[i % colors.length],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                'M${i + 1}',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ),
        ),
      );
    }

    if (memberCount > 3) {
      avatars.add(
        Transform.translate(
          offset: Offset(displayCount * -12.0, 0),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF9CCC65),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '+${memberCount - 3}',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
          ),
        ),
      );
    }

    return avatars;
  }

  Widget _buildOverviewTab(GroupEntity group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.push('/groups/${group.id}/fund');
            },
            child: _buildTotalFundBalanceCard(group),
          ),
          const SizedBox(height: 12),
          _buildSmartSpendingInsightCard(),
          const SizedBox(height: 12),
          _buildActivityCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTotalFundBalanceCard(GroupEntity group) {
    final fundBalance = (group.fund?.balance ?? 0) / 100.0;
    final totalSpent = group.totalSpent ?? 0.0;

    // Attempt to use budgetGoal, fallback to targetAmount
    final target =
        group.budgetGoal ?? ((group.fund?.targetAmount ?? 0) / 100.0);

    double progress = 0;
    if (target > 0) {
      progress = totalSpent / target;
      if (progress > 1) progress = 1.0;
    }

    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL FUND BALANCE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF757575),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(fundBalance),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFE3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Color(0xFF2F6C00)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${formatCurrency(totalSpent)}',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF757575)),
              ),
              Row(
                children: [
                  if (target > 0)
                    Text(
                      'Target: ${formatCurrency(target)}',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2F6C00)),
                    ),
                  if (target <= 0)
                    Text(
                      'Target: Not set',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        _showEditTargetDialog(context, group.id, target),
                    child: const Icon(Icons.edit,
                        size: 14, color: Color(0xFF2F6C00)),
                  ),
                ],
              ),
            ],
          ),
          if (target > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE8EFE3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2F6C00)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$percent% of budget used.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E1E1E),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditTargetDialog(
      BuildContext context, String groupId, double currentTarget) {
    final groupCubit = context.read<GroupCubit>();
    final controller = TextEditingController(
        text: currentTarget > 0 ? currentTarget.toString() : '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Target Amount',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Target Amount (\$)',
              hintText: 'e.g. 500',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                    color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                if (amount != null && amount > 0) {
                  groupCubit.updateGroup(groupId, {
                    'budgetGoal': amount,
                  });
                  Navigator.pop(context);
                } else if (amount == 0 || controller.text.trim().isEmpty) {
                  groupCubit.updateGroup(groupId, {
                    'budgetGoal': null,
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9CCC65),
                foregroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Save',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmartSpendingInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF9CCC65),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Smart Spending\nInsight',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E1E1E),
                            height: 1.2,
                          ),
                        ),
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFFEF6C00)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF1E1E1E),
                          height: 1.5,
                        ),
                        children: const [
                          TextSpan(text: 'You are '),
                          TextSpan(
                              text: '15% under budget',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F6C00))),
                          TextSpan(
                              text:
                                  ' for the travel segment. Suggesting an upgrade for the Oslo dinner?'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: Size.zero,
                ),
                child: Text('Show Recommendations',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF757575),
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: Size.zero,
                ),
                child: Text('Dismiss',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E1E)),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F6C00)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMockActivityItem(
            icon: Icons.receipt_long,
            bgColor: const Color(0xFFE8EFE3),
            iconColor: const Color(0xFF2F6C00),
            titleRich: [
              const TextSpan(
                  text: 'Marcus L. ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const TextSpan(text: 'paid '),
              const TextSpan(
                  text: '\$450.00 ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const TextSpan(text: 'for Flight Deposit.'),
            ],
            time: '2 hours ago',
          ),
          const SizedBox(height: 20),
          _buildMockActivityItem(
            icon: Icons.edit_outlined,
            bgColor: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFC62828),
            titleRich: [
              const TextSpan(
                  text: 'Sarah J. ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const TextSpan(text: 'updated the '),
              const TextSpan(
                  text: 'Itinerary ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const TextSpan(text: 'for Day 3.'),
            ],
            time: '5 hours ago',
          ),
          const SizedBox(height: 20),
          _buildMockActivityItem(
            icon: Icons.chat_bubble_outline,
            bgColor: const Color(0xFF9CCC65),
            iconColor: Colors.white,
            titleRich: [
              const TextSpan(
                  text: 'AI Chat ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const TextSpan(text: 'generated a packing list for the group.'),
            ],
            time: 'Yesterday',
          ),
          const SizedBox(height: 20),
          _buildMockActivityItem(
            icon: Icons.person_add_alt_1,
            bgColor: const Color(0xFFF5F5F5),
            iconColor: const Color(0xFF9E9E9E),
            titleRich: [
              const TextSpan(
                  text: 'Erik K. ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
              const TextSpan(text: 'joined the workspace.'),
            ],
            time: 'Yesterday',
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                '+ Log New Expense',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF757575)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockActivityItem({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required List<TextSpan> titleRich,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF424242),
                      height: 1.4),
                  children: titleRich,
                ),
              ),
              const SizedBox(height: 4),
              Text(time,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: const Color(0xFF9E9E9E))),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF1F3ED),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
