import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/bindings/injection_container.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F3),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('${RouteNames.groups}/create');
          if (context.mounted) {
            context.read<DashboardCubit>().loadDashboardData();
          }
        },
        backgroundColor: const Color(0xFF9CCC65),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        icon: const Icon(Icons.add, color: Color(0xFF1E1E1E)),
        label: Text(
          'CREATE NEW GROUP',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E1E1E),
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: _buildHeader(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildBalanceSheet(state.pendingSettlements),
                  ),
                  const SizedBox(height: 32),
                  _buildMyTripsSection(state.groups),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildNexoraAITip(),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildBottomGrid(state.pendingSettlements.length),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Nexora',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        // Bell icon
        GestureDetector(
          onTap: () async {
            await context.push(RouteNames.notifications);
            if (mounted) {
              context.read<DashboardCubit>().loadDashboardData();
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFE3),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.notifications_none, color: Color(0xFF2F6C00)),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSheet(List<SettlementEntity> pendingSettlements) {
    final authState = sl<AuthCubit>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';

    int totalYouOweCents = 0;
    int totalYouAreOwedCents = 0;

    for (var s in pendingSettlements) {
      if (s.fromUserId == currentUserId) {
        totalYouOweCents += s.amount;
      } else if (s.toUserId == currentUserId) {
        totalYouAreOwedCents += s.amount;
      }
    }

    const double monthlyLimitCents = 100000; // $1000 mock limit
    final double spendingRatio = monthlyLimitCents > 0
        ? (totalYouOweCents / monthlyLimitCents).clamp(0.0, 1.0)
        : 0.0;
    final String spendingPercentageText = '${(spendingRatio * 100).toInt()}%';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINANCIAL OVERVIEW',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.outline.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance Sheet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E1E1E),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.go(RouteNames.groups);
                },
                icon: const Icon(Icons.bolt, size: 16),
                label: Text(
                  'SETTLE UP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CCC65),
                  foregroundColor: const Color(0xFF1E1E1E),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE5E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward_rounded,
                                size: 14, color: AppColors.error),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'You Owe',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatCurrency(totalYouOweCents / 100),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCF2C7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_downward_rounded,
                                size: 14, color: Color(0xFF2F6C00)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'You are Owed',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F6C00),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatCurrency(totalYouAreOwedCents / 100),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2F6C00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: AppColors.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Monthly Spending Limit',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  spendingPercentageText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: spendingRatio,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF9CCC65)),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTripsSection(List<GroupEntity> groups) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'My Trips',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.go(RouteNames.groups);
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F6C00),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (groups.isEmpty)
          _buildEmptyTripsState(context)
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final dateFmt = DateFormat('MMM yyyy')
                    .format(group.createdAt)
                    .toUpperCase();
                final balance = (group.fund?.balance ?? 0) / 100;

                return GestureDetector(
                  onTap: () => context.push('${RouteNames.groups}/${group.id}'),
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Image
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EFE3),
                            image: group.avatarUrl != null &&
                                    group.avatarUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(group.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(16),
                          child: group.avatarUrl == null ||
                                  group.avatarUrl!.isEmpty
                              ? Center(
                                  child: Icon(Icons.terrain,
                                      size: 48,
                                      color:
                                          Colors.black.withValues(alpha: 0.1)))
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    dateFmt,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        group.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF1E1E1E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.more_vert,
                                        color: AppColors.outlineVariant),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children:
                                      _buildDynamicMembers(group.memberCount),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Spent',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      formatCurrency(balance),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E1E1E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDynamicMembers(int memberCount) {
    if (memberCount <= 0) return [];

    final List<Widget> avatars = [];
    final colors = [
      const Color(0xFFE0E0E0),
      const Color(0xFF9CCC65),
      const Color(0xFFCFD8DC),
      const Color(0xFFFFCC80),
      const Color(0xFFB39DDB),
    ];

    int displayCount = memberCount > 3 ? 3 : memberCount;

    for (int i = 0; i < displayCount; i++) {
      avatars.add(
        Transform.translate(
          offset: Offset(i * -8.0, 0),
          child: _buildMiniAvatar('M${i + 1}', colors[i % colors.length]),
        ),
      );
    }

    if (memberCount > 3) {
      avatars.add(
        Transform.translate(
          offset: Offset(displayCount * -8.0, 0),
          child: _buildMiniAvatar(
              '+${memberCount - 3}', const Color(0xFFF5F5F5),
              isCount: true),
        ),
      );
    }

    return avatars;
  }

  Widget _buildMiniAvatar(String text, Color bgColor, {bool isCount = false}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: isCount ? AppColors.outline : const Color(0xFF1E1E1E),
          ),
        ),
      ),
    );
  }

  Widget _buildNexoraAITip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F5212), // Dark green background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXORA AI TIP',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF9CCC65),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'You can save \$12 by settling Da Nang now.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF9CCC65), size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTripsState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F8E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.luggage_outlined,
              size: 40,
              color: Color(0xFF7CB342),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No trips yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Time to pack your bags!\nTap 'Create New Group' below to start.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomGrid(int pendingBillsCount) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF2F6C00)),
                const SizedBox(height: 12),
                Text(
                  'Pending',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingBillsCount Bills',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_add_alt_1, color: AppColors.outline),
                const SizedBox(height: 12),
                Text(
                  'Invites',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0 New',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
