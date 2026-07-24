import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_card.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key, required this.groupId, this.isTab = false});

  final String groupId;
  final bool isTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isTab) _buildHeader(),
              if (!isTab) const SizedBox(height: 32),
              const _TotalNetBalanceCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('Debt Network', icon: Icons.auto_awesome),
              const SizedBox(height: 16),
              const _DebtNetworkCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('You Owe',
                  icon: Icons.arrow_outward, iconColor: AppColors.error),
              const SizedBox(height: 16),
              _buildDebtList(isYouOwe: true),
              const SizedBox(height: 32),
              _buildSectionTitle('Owes You',
                  icon: Icons.call_received, iconColor: AppColors.primary),
              const SizedBox(height: 16),
              _buildDebtList(isYouOwe: false),
              const SizedBox(height: 32),
              const _NexoraIntelligenceCard(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.outlineVariant,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
            ),
            const SizedBox(width: 12),
            Text(
              'Nexora',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
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
                .copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildDebtList({required bool isYouOwe}) {
    // Mock data based on the UI
    return Column(
      children: [
        _DebtListItem(
          name: isYouOwe ? 'Alex M.' : 'Sarah K.',
          amount: isYouOwe ? '\$120.00' : '\$560.00',
          isYouOwe: isYouOwe,
          avatarUrl: 'https://i.pravatar.cc/150?img=${isYouOwe ? 11 : 5}',
        ),
        const SizedBox(height: 12),
        _DebtListItem(
          name: isYouOwe ? 'Emma R.' : 'David L.',
          amount: isYouOwe ? '\$220.00' : '\$1,200.00',
          isYouOwe: isYouOwe,
          avatarUrl: 'https://i.pravatar.cc/150?img=${isYouOwe ? 9 : 33}',
        ),
      ],
    );
  }
}

class _TotalNetBalanceCard extends StatelessWidget {
  const _TotalNetBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'TOTAL NET BALANCE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+\$1,420.00',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOU OWE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '\$340.00',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OWES YOU',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '\$1,760.00',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DebtNetworkCard extends StatelessWidget {
  const _DebtNetworkCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Most flows directed to you',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Mock network visualization
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNode('ME', true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text('\$1,200',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                        const Icon(Icons.arrow_forward,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                _buildNode('SK', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(String label, bool isMe) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: isMe ? AppColors.onSurface : AppColors.surfaceVariant,
      child: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isMe ? Colors.white : AppColors.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DebtListItem extends StatelessWidget {
  final String name;
  final String amount;
  final bool isYouOwe;
  final String avatarUrl;

  const _DebtListItem({
    required this.name,
    required this.amount,
    required this.isYouOwe,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isYouOwe ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (isYouOwe)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text('PAY NOW'),
              )
            else
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outline),
                  shape: const StadiumBorder(),
                ),
                child: const Text('REMIND'),
              ),
          ],
        ),
      ),
    );
  }
}

class _NexoraIntelligenceCard extends StatelessWidget {
  const _NexoraIntelligenceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryContainer, width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Nexora Intelligence',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You can simplify 3 debts by letting Nexora optimize the payment flow.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'OPTIMIZE & SETTLE ALL',
              color: AppColors.onSurface, // Black button
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
