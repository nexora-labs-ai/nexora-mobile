import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({
    required this.groupId,
    required this.expenseId,
    super.key,
  });

  final String groupId;
  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId),
        ),
        BlocProvider(
          create: (_) => sl<ExpenseCubit>()
            ..loadExpenseDetail(groupId: groupId, expenseId: expenseId),
        ),
      ],
      child: _ExpenseDetailView(groupId: groupId, expenseId: expenseId),
    );
  }
}

class _ExpenseDetailView extends StatefulWidget {
  const _ExpenseDetailView({required this.groupId, required this.expenseId});

  final String groupId;
  final String expenseId;

  @override
  State<_ExpenseDetailView> createState() => _ExpenseDetailViewState();
}

class _ExpenseDetailViewState extends State<_ExpenseDetailView> {
  List<CategoryEntity> _categories = [];
  List<GroupMemberEntity> _members = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final usecase = sl<GetCategoriesUseCase>();
    final result = await usecase(const NoParams());
    result.fold(
      (l) => null,
      (r) {
        if (mounted) {
          setState(() {
            _categories = r;
          });
        }
      },
    );
  }

  CategoryEntity _getCategory(ExpenseEntity expense) {
    if (expense.category != null) {
      return expense.category!;
    }
    return _categories.firstWhere(
      (c) => c.id == expense.categoryId,
      orElse: () => const CategoryEntity(
          id: '',
          name: 'Unknown Category',
          icon: '',
          color: '',
          isDefault: false),
    );
  }

  GroupMemberEntity _getMember(String userId) {
    return _members.firstWhere(
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

  String _getMemberName(String userId) {
    return _getMember(userId).displayName;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GroupCubit, GroupState>(
          listener: (context, state) {
            if (state is GroupDetailLoaded) {
              setState(() {
                _members = state.members;
              });
            }
          },
        ),
      ],
      child: BlocConsumer<ExpenseCubit, ExpenseState>(
        listenWhen: (prev, current) =>
            current is ExpenseDeleted || current is ExpenseFailureState,
        listener: (context, state) {
          if (state is ExpenseDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense deleted')),
            );
            context.pop();
          }
          if (state is ExpenseFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        buildWhen: (prev, current) =>
            current is ExpenseLoading ||
            current is ExpenseFailureState ||
            current is ExpenseDetailLoaded,
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F8F1),
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ExpenseFailureState) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F8F1),
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: ErrorView(
                message: state.message,
                onRetry: () => context.read<ExpenseCubit>().loadExpenseDetail(
                    groupId: widget.groupId, expenseId: widget.expenseId),
              ),
            );
          }

          if (state is ExpenseDetailLoaded) {
            final expense = state.expense;
            final category = _getCategory(expense);

            // Safe current user determination - for UI logic
            // In a real app we'd get this from AuthCubit, using a fallback for now
            const currentUserId = ''; // Will default to false for isMe check

            return Scaffold(
              backgroundColor: const Color(0xFFF5F8F1),
              body: SafeArea(
                child: Column(
                  children: [
                    // Header (App Bar)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: AppColors.ink),
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const Text(
                            'Expense Detail',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const Icon(Icons.all_inclusive,
                              color: AppColors.primary, size: 32),
                        ],
                      ),
                    ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<ExpenseCubit>().loadExpenseDetail(
                              groupId: widget.groupId,
                              expenseId: widget.expenseId);
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top Icon & Amount section
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(category.icon,
                                      style: const TextStyle(fontSize: 32)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'TOTAL SPENT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.outline,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatAmount(expense.amount, expense.currency),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                expense.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Date & Paid by Card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.calendar_today_outlined,
                                            color: AppColors.outline,
                                            size: 24),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Date & Time',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.outline)),
                                            Text(
                                              DateFormat(
                                                      'MMM dd, yyyy • h:mm a')
                                                  .format(expense.expenseDate
                                                      .toLocal()),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.ink),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20.0),
                                      child: Divider(
                                          height: 1,
                                          color:
                                              AppColors.surfaceContainerHigh),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.person_outline,
                                              color: AppColors.ink),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Paid by',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.outline)),
                                              Text(
                                                _getMemberName(
                                                    expense.paidByUserId),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.ink),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withValues(alpha: 0.05),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            expense.fundingSource ==
                                                    FundingSource.groupFund
                                                ? 'Group Fund'
                                                : 'Personal',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: AppColors.ink),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Split Breakdown section
                              const Text(
                                'Split Breakdown',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.ink),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    ...expense.splits
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final i = entry.key;
                                      final split = entry.value;
                                      final isPayer =
                                          split.userId == expense.paidByUserId;
                                      final payerNameParts =
                                          _getMemberName(expense.paidByUserId)
                                              .split(' ');
                                      final payerFirstName =
                                          payerNameParts.first;
                                      final memberName =
                                          _getMemberName(split.userId);
                                      final isMe =
                                          split.userId == currentUserId ||
                                              memberName.toLowerCase() == 'you';

                                      String? subtitle;
                                      if (expense.fundingSource ==
                                          FundingSource.personal) {
                                        if (isPayer && !isMe) {
                                          // Payer doesn't owe themselves
                                        } else if (!isPayer && isMe) {
                                          subtitle =
                                              'YOU OWE ${payerFirstName.toUpperCase()}';
                                        } else if (!isPayer && !isMe) {
                                          subtitle =
                                              'OWES ${payerFirstName.toUpperCase()}';
                                        }
                                      }

                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: isMe
                                                    ? AppColors.primaryContainer
                                                    : Colors.black
                                                        .withValues(alpha: 0.1),
                                                child: Text(
                                                    isMe
                                                        ? 'Y'
                                                        : _getMemberName(
                                                                split.userId)
                                                            .substring(0, 1)
                                                            .toUpperCase(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.ink)),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  isMe
                                                      ? 'You'
                                                      : _getMemberName(
                                                          split.userId),
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.ink),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatAmount(
                                                        split.amountOwed,
                                                        expense.currency),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors.ink),
                                                  ),
                                                  if (subtitle != null)
                                                    Text(
                                                      subtitle,
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color:
                                                              AppColors.error),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (i < expense.splits.length - 1)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16.0),
                                              child: Divider(
                                                  height: 1,
                                                  color: AppColors
                                                      .surfaceContainerHigh),
                                            ),
                                        ],
                                      );
                                    }),

                                    const SizedBox(height: 24),

                                    // Split progress bar
                                    Row(
                                      children: List.generate(
                                          expense.splits.length, (index) {
                                        final isFirst = index == 0;
                                        final isLast =
                                            index == expense.splits.length - 1;
                                        // Create a gradient of opacities for the bar
                                        final alpha =
                                            1.0 - (index * 0.3).clamp(0.0, 0.8);
                                        return Expanded(
                                          child: Container(
                                            height: 8,
                                            margin: EdgeInsets.only(
                                                right: isLast ? 0 : 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: alpha),
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                left: isFirst
                                                    ? const Radius.circular(4)
                                                    : Radius.zero,
                                                right: isLast
                                                    ? const Radius.circular(4)
                                                    : Radius.zero,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          expense.splitType ==
                                                  ExpenseSplitType.shares
                                              ? 'SPLIT EQUALLY'
                                              : 'EXACT AMOUNT',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.outline),
                                        ),
                                        Text(
                                          '${expense.splits.length} PEOPLE',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              if (expense.receiptUrl != null) ...[
                                const SizedBox(height: 32),
                                const Text(
                                  'Receipt Attachment',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink),
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (context, _, __) =>
                                            Scaffold(
                                          backgroundColor: Colors.black
                                              .withValues(alpha: 0.9),
                                          appBar: AppBar(
                                            backgroundColor: Colors.transparent,
                                            iconTheme: const IconThemeData(
                                                color: Colors.white),
                                            elevation: 0,
                                          ),
                                          body: Center(
                                            child: InteractiveViewer(
                                              minScale: 0.5,
                                              maxScale: 4.0,
                                              child: Image.network(
                                                  expense.receiptUrl!),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: AppColors.outlineVariant
                                              .withValues(alpha: 0.3)),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(expense.receiptUrl!),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withValues(alpha: 0.6),
                                          BlendMode.lighten,
                                        ),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.receipt_long,
                                                  size: 40,
                                                  color: AppColors.ink),
                                              SizedBox(height: 8),
                                              Text(
                                                'Tap to view full receipt',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.ink),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          right: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.8),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.fullscreen,
                                                    color: Colors.white,
                                                    size: 16),
                                                SizedBox(width: 4),
                                                Text('Expand',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(
                                  height: 48), // Padding before bottom buttons
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom Actions
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await context.push(
                                    '/groups/${widget.groupId}/expenses/${expense.id}/edit');
                                if (context.mounted && result == true) {
                                  context
                                      .read<ExpenseCubit>()
                                      .loadExpenseDetail(
                                          groupId: widget.groupId,
                                          expenseId: widget.expenseId);
                                }
                              },
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.onPrimaryContainer),
                              label: const Text(
                                'Edit Expense',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onPrimaryContainer),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.ink, width: 2),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.ink),
                              iconSize: 28,
                              padding: const EdgeInsets.all(16),
                              onPressed: () =>
                                  _confirmDelete(context, expense.id),
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

          return Scaffold(
            backgroundColor: const Color(0xFFF5F8F1),
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String expenseId) async {
    final cubit = context.read<ExpenseCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      cubit.deleteExpense(groupId: widget.groupId, expenseId: expenseId);
    }
  }
}

String _formatAmount(int amount, String currency) {
  final formatter = NumberFormat.currency(
    symbol: _getCurrencySymbol(currency),
    decimalDigits: currency == 'VND' ? 0 : 2,
  );
  return formatter.format(minorUnitsToDouble(amount));
}

String _getCurrencySymbol(String code) {
  return switch (code) {
    'VND' => '₫',
    'USD' => '\$',
    'EUR' => '€',
    'JPY' => '¥',
    'GBP' => '£',
    'SGD' => 'S\$',
    _ => code,
  };
}
