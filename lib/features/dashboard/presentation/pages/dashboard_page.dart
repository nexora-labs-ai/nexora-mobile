import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/bindings/injection_container.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../settlements/domain/entities/settlement_entity.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardCubit>()..loadDashboardData(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentTabIndex = 0; // 0: Groups, 1: Financial Overview

  // Filter states for financial overview
  String _selectedGroupFilter = 'All';
  String _selectedTypeFilter = 'All'; // 'All', 'You Owe', 'Owes You'

  // Search for groups
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5EA),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('${RouteNames.groups}/create');
                if (context.mounted) {
                  context.read<DashboardCubit>().loadDashboardData();
                }
              },
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add,
                  color: AppColors.onPrimaryContainer, size: 28),
            )
          : null,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: _buildHeader(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildToggle(),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _currentTabIndex == 0
                      ? _buildGroupsView(state.groups)
                      : _buildFinancialView(
                          state.pendingSettlements, state.groups),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Nexora',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: AppColors.onSurface),
                onPressed: () => context.push(RouteNames.notifications),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 0),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _currentTabIndex == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _currentTabIndex == 0
                      ? [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _currentTabIndex == 1 ? 'My Groups' : 'Groups',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _currentTabIndex == 0
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                    fontWeight: _currentTabIndex == 0
                        ? FontWeight.bold
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTabIndex = 1),
              child: Container(
                decoration: BoxDecoration(
                  color: _currentTabIndex == 1
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Financial Overview',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _currentTabIndex == 1
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSurfaceVariant,
                    fontWeight: _currentTabIndex == 1
                        ? FontWeight.bold
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsView(List<GroupEntity> groups) {
    final filteredGroups = groups
        .where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search groups...',
              hintStyle: GoogleFonts.inter(color: AppColors.outline),
              border: InputBorder.none,
              icon: const Icon(Icons.search, color: AppColors.outline),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...filteredGroups.map((group) {
          final balance = (group.fund?.balance ?? 0) / 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => context.push('${RouteNames.groups}/${group.id}'),
              child: _buildGroupCard(
                title: group.name,
                subtitle: '${group.memberCount} members',
                amount: '\$${balance.toStringAsFixed(2)}',
                amountLabel: 'FUND',
                amountColor: const Color(0xFF2F6C00),
                imageUrl: group.avatarUrl,
                iconData: group.avatarUrl == null ? Icons.group : null,
              ),
            ),
          );
        }),
        if (filteredGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
                child: Text('No groups found',
                    style: GoogleFonts.inter(color: AppColors.outline))),
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildGroupCard({
    required String title,
    required String subtitle,
    required String amount,
    required String amountLabel,
    required Color amountColor,
    String? imageUrl,
    IconData? iconData,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: imageUrl == null ? AppColors.surfaceContainerHigh : null,
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: (imageUrl == null || imageUrl.isEmpty) && iconData != null
                ? Icon(iconData, color: AppColors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                amount,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amountLabel,
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialView(
      List<SettlementEntity> settlements, List<GroupEntity> groups) {
    final authState = sl<AuthCubit>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';

    List<SettlementEntity> filtered = settlements.toList();

    if (_selectedTypeFilter == 'You Owe') {
      filtered = filtered.where((s) => s.fromUserId == currentUserId).toList();
    } else if (_selectedTypeFilter == 'Owes You') {
      filtered = filtered.where((s) => s.toUserId == currentUserId).toList();
    }

    if (_selectedGroupFilter != 'All') {
      filtered =
          filtered.where((s) => s.groupId == _selectedGroupFilter).toList();
    }

    filtered.sort((a, b) => b.amount.compareTo(a.amount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(groups),
        const SizedBox(height: 24),
        ...filtered.map((s) {
          final isYouOwe = s.fromUserId == currentUserId;
          final otherUserName = isYouOwe
              ? (s.toUserName ?? 'Unknown')
              : (s.fromUserName ?? 'Unknown');
          final otherUserAvatar =
              isYouOwe ? s.toUserAvatarUrl : s.fromUserAvatarUrl;
          final groupName = groups
              .firstWhere((g) => g.id == s.groupId,
                  orElse: () => GroupEntity(
                      id: '',
                      name: 'Unknown',
                      createdAt: DateTime.now(),
                      memberCount: 0,
                      currency: 'USD',
                      createdBy: ''))
              .name;

          final amountStr = '\$${(s.amount / 100).toStringAsFixed(2)}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSettlementCard(
              name: otherUserName,
              subtitle:
                  '$groupName • ${isYouOwe ? 'You owe $amountStr' : 'Owes you $amountStr'}',
              subtitleColor:
                  isYouOwe ? AppColors.error : const Color(0xFF2F6C00),
              buttonText: isYouOwe ? 'Settle' : 'Remind',
              buttonColor: isYouOwe
                  ? AppColors.primaryContainer
                  : Colors.black.withValues(alpha: 0.08),
              buttonTextColor: isYouOwe
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
              imageUrl: otherUserAvatar ?? '',
              onTapButton: () =>
                  context.push('${RouteNames.groups}/${s.groupId}/settlements'),
            ),
          );
        }),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
                child: Text('No pending settlements',
                    style: GoogleFonts.inter(color: AppColors.outline))),
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFilters(List<GroupEntity> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Types', _selectedTypeFilter == 'All',
                  () => setState(() => _selectedTypeFilter = 'All')),
              _buildFilterChip('You Owe', _selectedTypeFilter == 'You Owe',
                  () => setState(() => _selectedTypeFilter = 'You Owe')),
              _buildFilterChip('Owes You', _selectedTypeFilter == 'Owes You',
                  () => setState(() => _selectedTypeFilter = 'Owes You')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Groups', _selectedGroupFilter == 'All',
                  () => setState(() => _selectedGroupFilter = 'All')),
              ...groups.map((g) => _buildFilterChip(
                  g.name,
                  _selectedGroupFilter == g.id,
                  () => setState(() => _selectedGroupFilter = g.id))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    isSelected ? AppColors.primary : AppColors.outlineVariant),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementCard({
    required String name,
    required String subtitle,
    required Color subtitleColor,
    required String buttonText,
    required Color buttonColor,
    required Color buttonTextColor,
    required String imageUrl,
    required VoidCallback onTapButton,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTapButton,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              minimumSize: Size.zero,
            ),
            child: Text(
              buttonText,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
