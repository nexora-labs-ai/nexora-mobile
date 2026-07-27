import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexora_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nexora_mobile/features/auth/presentation/cubit/auth_state.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../../../shared/enums/app_enums.dart';

import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/optimized_settlement_entity.dart';
import '../bloc/settlement_bloc.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen(
      {super.key, required this.groupId, this.isTab = false});

  final String groupId;
  final bool isTab;

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettlementBloc>(
          create: (context) =>
              sl<SettlementBloc>()..add(LoadSettlements(widget.groupId)),
        ),
        BlocProvider<GroupCubit>(
          create: (context) =>
              sl<GroupCubit>()..loadGroupDetail(widget.groupId),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            bloc: sl<AuthCubit>(),
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return const SizedBox();
              }
              final currentUserId = authState.user.id;

              return BlocBuilder<GroupCubit, GroupState>(
                builder: (context, groupState) {
                  if (groupState is GroupLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (groupState is GroupFailureState) {
                    return ErrorView(
                      message: groupState.message,
                      onRetry: () => context
                          .read<GroupCubit>()
                          .loadGroupDetail(widget.groupId),
                    );
                  }

                  if (groupState is GroupDetailLoaded) {
                    return BlocBuilder<SettlementBloc, SettlementState>(
                      builder: (context, settlementState) {
                        if (settlementState is SettlementLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (settlementState is SettlementError) {
                          return ErrorView(
                            message: settlementState.message,
                            onRetry: () => context
                                .read<SettlementBloc>()
                                .add(LoadSettlements(widget.groupId)),
                          );
                        }

                        if (settlementState is SettlementLoaded) {
                          return _buildContent(
                              context,
                              currentUserId,
                              groupState.group,
                              groupState.members,
                              settlementState);
                        }

                        return const SizedBox();
                      },
                    );
                  }

                  return const SizedBox();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String currentUserId,
    GroupEntity group,
    List<GroupMemberEntity> members,
    SettlementLoaded settlementState,
  ) {
    final youOweList = settlementState.optimizedSettlements
        .where((s) => s.fromUserId == currentUserId)
        .toList();
    final owesYouList = settlementState.optimizedSettlements
        .where((s) => s.toUserId == currentUserId)
        .toList();

    int totalYouOwe = youOweList.fold<int>(0, (sum, item) => sum + item.amount);
    int totalOwesYou =
        owesYouList.fold<int>(0, (sum, item) => sum + item.amount);

    // Total raw settlements vs optimized for efficiency score
    int rawCount = settlementState.settlements.length;
    int optimizedCount = settlementState.optimizedSettlements.length;
    double efficiency = 0;
    if (rawCount > 0) {
      efficiency = ((rawCount - optimizedCount) / rawCount) * 100;
      if (efficiency < 0) efficiency = 0;
    } else if (optimizedCount == 0) {
      efficiency = 100; // if no debts, 100% efficient
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SettlementBloc>().add(LoadSettlements(widget.groupId));
        context.read<GroupCubit>().loadGroupDetail(widget.groupId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EBEA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text('YOU OWE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.error,
                                  letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text(_formatAmount(totalYouOwe, group.currency),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text('OWES YOU',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Text(_formatAmount(totalOwesYou, group.currency),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (rawCount > 1 && optimizedCount < rawCount) ...[
              const SizedBox(height: 16),
              _EfficiencyScoreCard(
                efficiencyPercentage: efficiency.toInt(),
                rawTransactions: rawCount,
                optimizedTransactions: optimizedCount,
              ),
            ],
            const SizedBox(height: 32),
            if (youOweList.isNotEmpty || owesYouList.isNotEmpty) ...[
              _DebtNetworkCard(
                youOweList: youOweList,
                owesYouList: owesYouList,
                members: members,
                currentUserId: currentUserId,
              ),
              const SizedBox(height: 32),
            ],
            if (youOweList.isNotEmpty) ...[
              _buildSectionTitle('You Owe',
                  icon: Icons.call_made, iconColor: AppColors.error),
              const SizedBox(height: 16),
              ...youOweList.map((settlement) => _DebtListItem(
                    settlement: settlement,
                    isYouOwe: true,
                    member: _getMember(members, settlement.toUserId),
                    currency: group.currency,
                  )),
              const SizedBox(height: 32),
            ],
            if (owesYouList.isNotEmpty) ...[
              _buildSectionTitle('Owes You',
                  icon: Icons.call_received, iconColor: AppColors.primary),
              const SizedBox(height: 16),
              ...owesYouList.map((settlement) => _DebtListItem(
                    settlement: settlement,
                    isYouOwe: false,
                    member: _getMember(members, settlement.fromUserId),
                    currency: group.currency,
                  )),
              const SizedBox(height: 32),
            ],
            if (youOweList.isEmpty && owesYouList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'All settled up! No debts.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.outline,
                        ),
                  ),
                ),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  GroupMemberEntity _getMember(List<GroupMemberEntity> members, String userId) {
    return members.firstWhere(
      (m) => m.userId == userId,
      orElse: () => GroupMemberEntity(
        id: '',
        groupId: '',
        userId: userId,
        role: GroupRole.member,
        joinedAt: DateTime.now(),
        displayName: 'Unknown',
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24, color: iconColor ?? AppColors.onSurface),
          const SizedBox(width: 8),
        ],
        Text(title,
            style: AppTextStyles.headlineMedium
                .copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _EfficiencyScoreCard extends StatelessWidget {
  final int efficiencyPercentage;
  final int rawTransactions;
  final int optimizedTransactions;

  const _EfficiencyScoreCard({
    required this.efficiencyPercentage,
    required this.rawTransactions,
    required this.optimizedTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFAEEA66), // Bright green background from mockup
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Efficiency Score',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF4C7B19), // Darker green text
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optimized Settlement',
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF284D04),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$efficiencyPercentage%',
            style: AppTextStyles.displayLarge.copyWith(
              color: const Color(0xFF1E4000),
              fontWeight: FontWeight.w900,
              fontSize: 64,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nexora AI has reduced $rawTransactions transactions into $optimizedTransactions easy payments.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF35610F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtListItem extends StatelessWidget {
  final OptimizedSettlementEntity settlement;
  final bool isYouOwe;
  final GroupMemberEntity member;
  final String currency;

  const _DebtListItem({
    required this.settlement,
    required this.isYouOwe,
    required this.member,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatted = _formatAmount(settlement.amount, currency);
    final initials = member.displayName.length >= 2
        ? member.displayName.substring(0, 2).toUpperCase()
        : (member.displayName.isNotEmpty
            ? member.displayName[0].toUpperCase()
            : '?');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isYouOwe
                    ? const Color(
                        0xFFE8F5E9) // Light green background for initials
                    : AppColors
                        .primary, // Dark green background for Owed to you
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isYouOwe ? AppColors.ink : Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.displayName,
                        style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 4),
                    Text(
                      'Group expenses balance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountFormatted,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isYouOwe
                          ? const Color(0xFFC62828)
                          : AppColors.primary, // Deep red for owe
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isYouOwe)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFF9CCC65), // Vibrant light green from mockup
                        foregroundColor: AppColors.ink, // Dark text
                        elevation: 0,
                        minimumSize: const Size(80, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('PAY NOW',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  else
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder sent!')),
                        );
                      },
                      child: Text(
                        'REMIND',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(int amount, String currency) {
  return '\$${(amount / 100).toStringAsFixed(2)}';
}

class _DebtNetworkCard extends StatelessWidget {
  final List<OptimizedSettlementEntity> youOweList;
  final List<OptimizedSettlementEntity> owesYouList;
  final List<GroupMemberEntity> members;
  final String currentUserId;

  const _DebtNetworkCard({
    required this.youOweList,
    required this.owesYouList,
    required this.members,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Find biggest connection
    OptimizedSettlementEntity? biggestOwe;
    OptimizedSettlementEntity? biggestOwed;

    if (youOweList.isNotEmpty) {
      biggestOwe = youOweList
          .reduce((curr, next) => curr.amount > next.amount ? curr : next);
    }
    if (owesYouList.isNotEmpty) {
      biggestOwed = owesYouList
          .reduce((curr, next) => curr.amount > next.amount ? curr : next);
    }

    bool isOwed = false;
    OptimizedSettlementEntity? primarySettlement;

    if (biggestOwe != null && biggestOwed != null) {
      if (biggestOwed.amount >= biggestOwe.amount) {
        primarySettlement = biggestOwed;
        isOwed = true;
      } else {
        primarySettlement = biggestOwe;
      }
    } else if (biggestOwe != null) {
      primarySettlement = biggestOwe;
    } else if (biggestOwed != null) {
      primarySettlement = biggestOwed;
      isOwed = true;
    }

    if (primarySettlement == null) return const SizedBox();

    final targetUserId =
        isOwed ? primarySettlement.fromUserId : primarySettlement.toUserId;
    final targetMember = members.firstWhere((m) => m.userId == targetUserId,
        orElse: () => GroupMemberEntity(
            id: '',
            groupId: '',
            userId: targetUserId,
            role: GroupRole.member,
            joinedAt: DateTime.now(),
            displayName: 'Unknown'));

    final targetInitials = targetMember.displayName
        .substring(0, targetMember.displayName.length >= 2 ? 2 : 1)
        .toUpperCase();
    final bool isActive = isOwed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Debt Network',
                style: AppTextStyles.headlineMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            const Icon(Icons.auto_awesome, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _DebtNetworkPainter(isOwed: isOwed),
              ),

              // ME Node
              Positioned(
                left: 40,
                child: _build3DNode(
                  text: 'ME',
                  isMe: true,
                  color: Colors.white,
                  textColor: AppColors.ink,
                  borderColor: AppColors.primary,
                ),
              ),

              // Target Node
              Positioned(
                right: 40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _build3DNode(
                      text: targetInitials,
                      isMe: false,
                      color: AppColors.primary,
                      textColor: Colors.white,
                      borderColor: Colors.transparent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      targetMember.displayName,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ),

              // Insight Pill
              Positioned(
                bottom: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryContainer
                        : AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.outline.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOwed
                            ? 'Most flows directed to you'
                            : 'Most flows directed away',
                        style: AppTextStyles.labelMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build3DNode({
    required String text,
    required bool isMe,
    required Color color,
    required Color textColor,
    required Color borderColor,
  }) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background shadow disk
          Positioned(
            left: isMe ? 6 : -6,
            top: 6,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: isMe ? 0.0 : 0.8),
                border: isMe
                    ? Border.all(
                        color: borderColor.withValues(alpha: 0.5), width: 1.5)
                    : null,
              ),
            ),
          ),
          // Foreground disk
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isMe ? Border.all(color: borderColor, width: 2) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: AppTextStyles.titleMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtNetworkPainter extends CustomPainter {
  final bool isOwed;

  _DebtNetworkPainter({required this.isOwed});

  @override
  void paint(Canvas canvas, Size size) {
    final paintSolid = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final paintDashed = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final paintGhostNode = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2 - 20);
    final leftNode = Offset(70, center.dy);
    final rightNode = Offset(size.width - 70, center.dy);

    // Draw ghost nodes vertically
    canvas.drawCircle(Offset(center.dx, center.dy - 50), 12, paintGhostNode);
    canvas.drawCircle(Offset(center.dx, center.dy + 50), 12, paintGhostNode);

    // Draw connecting vertical faint line
    canvas.drawLine(Offset(center.dx, center.dy - 38),
        Offset(center.dx, center.dy + 38), paintGhostNode);

    // Create curved paths between nodes
    final pathBottom = Path();
    pathBottom.moveTo(leftNode.dx, leftNode.dy);
    pathBottom.quadraticBezierTo(
        center.dx, center.dy + 40, rightNode.dx, rightNode.dy);

    final pathTop = Path();
    pathTop.moveTo(leftNode.dx, leftNode.dy);
    pathTop.quadraticBezierTo(
        center.dx, center.dy - 40, rightNode.dx, rightNode.dy);

    if (isOwed) {
      canvas.drawPath(pathBottom, paintSolid);
      _drawDashedPath(canvas, pathTop, paintDashed);
    } else {
      canvas.drawPath(pathBottom, paintSolid..color = AppColors.error);
      _drawDashedPath(canvas, pathTop, paintDashed);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var distance = 0.0;

    // Instead of using complex path metrics which requires dart:ui which is imported,
    // we can use a simpler approach or path.computeMetrics().
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
