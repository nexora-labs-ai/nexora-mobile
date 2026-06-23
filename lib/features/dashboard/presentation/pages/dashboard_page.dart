import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(),
                  const SizedBox(height: 24),
                  const Text('Recent Activity',
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 12),
                  // TODO: wire to DashboardCubit
                  const _EmptyActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
          const SizedBox(height: 4),
          Text('₫ 0',
              style: AppTextStyles.displayMedium.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          const Row(
            children: [
              _MiniStat(
                  label: 'You owe', amount: '₫ 0', color: Colors.redAccent),
              SizedBox(width: 24),
              _MiniStat(
                  label: 'You\'re owed',
                  amount: '₫ 0',
                  color: Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.amount, required this.color});

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white60)),
        Text(amount, style: AppTextStyles.titleMedium.copyWith(color: color)),
      ],
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.timeline_outlined,
                size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text('No recent activity',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
