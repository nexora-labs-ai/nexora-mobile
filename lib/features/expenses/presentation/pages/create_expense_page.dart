import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_split_widget.dart';

class CreateExpensePage extends StatelessWidget {
  const CreateExpensePage({required this.groupId, this.expenseId, super.key});

  final String groupId;
  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = sl<ExpenseCubit>();
            if (expenseId != null) {
              cubit.loadExpenseDetail(groupId: groupId, expenseId: expenseId!);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId),
        ),
      ],
      child: _CreateExpensePageContent(groupId: groupId, expenseId: expenseId),
    );
  }
}

class _CreateExpensePageContent extends StatefulWidget {
  const _CreateExpensePageContent({required this.groupId, this.expenseId});

  final String groupId;
  final String? expenseId;

  @override
  State<_CreateExpensePageContent> createState() =>
      _CreateExpensePageContentState();
}

class _CreateExpensePageContentState extends State<_CreateExpensePageContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String _selectedCurrency = AppConstants.defaultCurrency;
  ExpenseSplitType _selectedSplitType = ExpenseSplitType.shares;
  FundingSource _selectedFundingSource = FundingSource.personal;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _splits = [];
  List<CategoryEntity> _categories = [];
  List<GroupMemberEntity> _members = [];
  bool _isAnalyzingReceipt = false;
  bool _isUploadingReceipt = false;
  String? _receiptUrl;
  String? _selectedPaidByUserId;

  @override
  void initState() {
    super.initState();
    final authState = sl<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _selectedPaidByUserId = authState.user.id;
    }
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
            if (_selectedCategory == null && _categories.isNotEmpty) {
              _selectedCategory = _categories.first.id;
            } else if (_selectedCategory != null &&
                _categories.isNotEmpty &&
                !_categories.any((c) => c.id == _selectedCategory)) {
              // If the selected category is not in the list (e.g. deleted), fallback
              _selectedCategory = _categories.first.id;
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (pickedFile == null) return;

    setState(() {
      _isAnalyzingReceipt = true;
    });

    try {
      final dio = sl<DioClient>().dio;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pickedFile.path),
      });

      final response =
          await dio.post('/expenses/analyze-receipt', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (mounted) {
          setState(() {
            if (data['amount'] != null) {
              _amountController.text = data['amount'].toString();
            }
            if (data['merchant'] != null) {
              _titleController.text = data['merchant'].toString();
            }
            if (data['date'] != null) {
              try {
                _selectedDate = DateTime.parse(data['date'].toString());
              } catch (_) {}
            }
            if (data['receiptUrl'] != null) {
              _receiptUrl = data['receiptUrl'].toString();
            }
            if (data['categoryId'] != null && _categories.isNotEmpty) {
              final catId = data['categoryId'].toString();
              if (_categories.any((c) => c.id == catId)) {
                _selectedCategory = catId;
              }
            } else if (data['category'] != null && _categories.isNotEmpty) {
              final catName = data['category'].toString().toLowerCase();
              final matchedCat = _categories.firstWhere(
                (c) => c.name.toLowerCase().contains(catName),
                orElse: () => _categories.first,
              );
              _selectedCategory = matchedCat.id;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Receipt analyzed successfully! Please verify the details.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to analyze receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzingReceipt = false;
        });
      }
    }
  }

  Future<void> _uploadEvidence() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isUploadingReceipt = true);

      final dio = sl<DioClient>().dio;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pickedFile.path),
      });

      final response =
          await dio.post(ApiEndpoints.uploadReceipt, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _receiptUrl = response.data['receiptUrl'] as String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload receipt: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingReceipt = false);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final authState = sl<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }
    final currentUserId = authState.user.id;
    final paidBy = _selectedPaidByUserId ?? currentUserId;

    final cubit = context.read<ExpenseCubit>();

    final amount = stringToMinorUnits(_amountController.text);
    if (_selectedSplitType == ExpenseSplitType.exact) {
      int splitSum = 0;
      for (final s in _splits) {
        splitSum += (s['amount'] as num?)?.toInt() ?? 0;
      }
      if (splitSum != amount) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Split total (${formatMinorUnits(splitSum)}) must equal amount (${formatMinorUnits(amount)}).')));
        return;
      }
    }

    if (widget.expenseId != null) {
      cubit.updateExpense(
        UpdateExpenseParams(
          groupId: widget.groupId,
          expenseId: widget.expenseId!,
          fields: {
            'title': _titleController.text.trim(),
            'amount': stringToMinorUnits(_amountController.text),
            'currency': _selectedCurrency,
            'categoryId': _selectedCategory ?? '',
            'date': _selectedDate.toUtc().toIso8601String(),
            'fundingSource': _selectedFundingSource.toApi(),
            'paidByUserId': paidBy,
            'splitType': _selectedSplitType.toApi(),
            'splits': _splits,
            'description': _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            if (_receiptUrl != null) 'receiptUrl': _receiptUrl,
          },
        ),
      );
    } else {
      cubit.createExpense(
        CreateExpenseParams(
          groupId: widget.groupId,
          title: _titleController.text.trim(),
          amount: stringToMinorUnits(_amountController.text),
          currency: _selectedCurrency,
          paidByUserId: paidBy,
          categoryId: _selectedCategory ?? '',
          fundingSource: _selectedFundingSource.toApi(),
          expenseDate: _selectedDate,
          splitType: _selectedSplitType.toApi(),
          splits: _splits,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          receiptUrl: _receiptUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<AuthCubit>().state is AuthAuthenticated
        ? (sl<AuthCubit>().state as AuthAuthenticated).user.id
        : null;

    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCreated || state is ExpenseUpdated) {
          context.pop(true);
        }
        if (state is ExpenseFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
        if (state is ExpenseDetailLoaded) {
          final expense = state.expense;
          setState(() {
            _titleController.text = expense.title;
            _amountController.text =
                minorUnitsToDouble(expense.amount).toString();
            _descriptionController.text = expense.description ?? '';
            if (_categories.isEmpty) {
              _selectedCategory = expense.categoryId;
            } else {
              _selectedCategory =
                  _categories.any((c) => c.id == expense.categoryId)
                      ? expense.categoryId
                      : _categories.first.id;
            }
            _selectedPaidByUserId = expense.paidByUserId;
            _receiptUrl = expense.receiptUrl;
            _selectedCurrency = expense.currency;
            _selectedFundingSource = expense.fundingSource;
            _selectedSplitType = expense.splitType;
            _selectedDate = expense.expenseDate;
            _splits = expense.splits
                .map((s) => {
                      'userId': s.userId,
                      'amount': s.amountOwed,
                      'shares': s.shares
                    })
                .toList();
          });
        }
      },
      child: BlocListener<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupDetailLoaded) {
            setState(() {
              _members = state.members;
              if (widget.expenseId == null) {
                _selectedCurrency = state.group.currency;
              }
            });
          }
        },
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            final isLoading = state is ExpenseCreating ||
                state is ExpenseUpdating ||
                state is ExpenseLoading;

            final hasAmount = _amountController.text.isNotEmpty &&
                _amountController.text != '0' &&
                _amountController.text != '0.00';
            final currencySymbol =
                NumberFormat.simpleCurrency(name: _selectedCurrency)
                    .currencySymbol;
            final selectedPaidByMember =
                _members.cast<GroupMemberEntity?>().firstWhere(
                      (m) =>
                          m?.userId == (_selectedPaidByUserId ?? currentUserId),
                      orElse: () => null,
                    );
            final selectedCategoryObj =
                _categories.cast<CategoryEntity?>().firstWhere(
                      (c) => c?.id == _selectedCategory,
                      orElse: () =>
                          _categories.isNotEmpty ? _categories.first : null,
                    );

            return Scaffold(
              backgroundColor: AppColors.canvas,
              body: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => context.pop(),
                            icon:
                                const Icon(Icons.close, color: AppColors.error),
                            label: const Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600)),
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                          ),
                          Text(
                            widget.expenseId == null
                                ? 'New Expense'
                                : 'Edit Expense',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.document_scanner_outlined,
                                color: AppColors.primary),
                            onPressed:
                                _isAnalyzingReceipt ? null : _scanReceipt,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // AMOUNT HEADER
                              if (selectedCategoryObj != null)
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(selectedCategoryObj.icon,
                                          style: const TextStyle(fontSize: 32)),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              const Text(
                                'TOTAL SPENT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.outline,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      currencySymbol,
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: hasAmount
                                            ? AppColors.ink
                                            : AppColors.outlineVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IntrinsicWidth(
                                      child: TextFormField(
                                        controller: _amountController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 64,
                                          fontWeight: FontWeight.w900,
                                          color: hasAmount
                                              ? AppColors.ink
                                              : AppColors.outlineVariant,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: '0.00',
                                          hintStyle: TextStyle(
                                              color: AppColors.outlineVariant),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          fillColor: Colors.transparent,
                                          filled: false,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        validator:
                                            FormValidators.positiveAmount,
                                        onChanged: (val) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                controller: _titleController,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'What was this for?',
                                  hintStyle:
                                      TextStyle(color: AppColors.outline),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                validator: (v) => FormValidators.required(v,
                                    fieldName: 'Description'),
                              ),
                              const SizedBox(height: 24),

                              // Date and Paid By Card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                        );
                                        if (picked != null) {
                                          setState(
                                              () => _selectedDate = picked);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.calendar_today_outlined,
                                              color: AppColors.outline),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Date & Time',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.outline)),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat('MMM dd, yyyy')
                                                    .format(_selectedDate),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.ink,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Divider(
                                          color: AppColors.outlineVariant
                                              .withValues(alpha: 0.3),
                                          height: 1),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) => Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    24)),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16, bottom: 24),
                                                  child: SafeArea(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 4,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .outlineVariant,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        const Text('Paid By',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .ink)),
                                                        const SizedBox(
                                                            height: 16),
                                                        Flexible(
                                                          child: ListView(
                                                            shrinkWrap: true,
                                                            children: _members
                                                                .map((m) =>
                                                                    ListTile(
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                24,
                                                                            vertical:
                                                                                8),
                                                                        leading:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              20,
                                                                          backgroundColor: _selectedPaidByUserId == m.userId
                                                                              ? AppColors.primaryContainer
                                                                              : AppColors.surfaceContainerLowest,
                                                                          backgroundImage: m.avatarUrl != null
                                                                              ? NetworkImage(m.avatarUrl!)
                                                                              : null,
                                                                          child: m.avatarUrl == null
                                                                              ? const Icon(Icons.person, color: AppColors.outline)
                                                                              : null,
                                                                        ),
                                                                        title: Text(
                                                                            m.displayName,
                                                                            style: TextStyle(fontWeight: _selectedPaidByUserId == m.userId ? FontWeight.bold : FontWeight.normal)),
                                                                        trailing: _selectedPaidByUserId == m.userId ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                                                                        onTap: () {
                                                                          setState(() =>
                                                                              _selectedPaidByUserId = m.userId);
                                                                          Navigator.pop(
                                                                              context);
                                                                        }))
                                                                .toList(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: AppColors
                                                      .surfaceContainerHighest,
                                                  backgroundImage:
                                                      selectedPaidByMember
                                                                  ?.avatarUrl !=
                                                              null
                                                          ? NetworkImage(
                                                              selectedPaidByMember!
                                                                  .avatarUrl!)
                                                          : null,
                                                  child: selectedPaidByMember
                                                              ?.avatarUrl ==
                                                          null
                                                      ? const Icon(
                                                          Icons.person_outline,
                                                          color:
                                                              AppColors.outline)
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text('Paid by',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .outline)),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        selectedPaidByMember
                                                                ?.displayName ??
                                                            'You',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                AppColors.ink,
                                                            fontSize: 16),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .surfaceContainerLowest,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () => setState(() =>
                                                        _selectedFundingSource =
                                                            FundingSource
                                                                .personal),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: _selectedFundingSource ==
                                                                FundingSource
                                                                    .personal
                                                            ? AppColors
                                                                .primaryContainer
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text('Personal',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: _selectedFundingSource ==
                                                                      FundingSource
                                                                          .personal
                                                                  ? AppColors
                                                                      .onPrimaryContainer
                                                                  : AppColors
                                                                      .ink)),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () => setState(() =>
                                                        _selectedFundingSource =
                                                            FundingSource
                                                                .groupFund),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: _selectedFundingSource ==
                                                                FundingSource
                                                                    .groupFund
                                                            ? AppColors
                                                                .primaryContainer
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text('Fund',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: _selectedFundingSource ==
                                                                      FundingSource
                                                                          .groupFund
                                                                  ? AppColors
                                                                      .onPrimaryContainer
                                                                  : AppColors
                                                                      .ink)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Category section
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 4.0, bottom: 8.0),
                                child: Text('Category',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24)),
                                      ),
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 24),
                                      child: SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: AppColors.outlineVariant,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('Select Category',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.ink)),
                                            const SizedBox(height: 16),
                                            Flexible(
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: _categories
                                                    .map((c) => ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 24,
                                                                vertical: 8),
                                                        leading: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _selectedCategory ==
                                                                    c.id
                                                                ? AppColors
                                                                    .primaryContainer
                                                                : AppColors
                                                                    .surfaceContainerLowest,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Text(c.icon,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          24)),
                                                        ),
                                                        title: Text(c.name,
                                                            style: TextStyle(
                                                                fontWeight: _selectedCategory ==
                                                                        c.id
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal)),
                                                        trailing: _selectedCategory ==
                                                                c.id
                                                            ? const Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: AppColors
                                                                    .primary)
                                                            : null,
                                                        onTap: () {
                                                          setState(() =>
                                                              _selectedCategory =
                                                                  c.id);
                                                          Navigator.pop(
                                                              context);
                                                        }))
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      if (selectedCategoryObj != null) ...[
                                        Text(selectedCategoryObj.icon,
                                            style:
                                                const TextStyle(fontSize: 24)),
                                        const SizedBox(width: 12),
                                        Text(selectedCategoryObj.name,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.ink)),
                                      ] else
                                        const Text('Select Category',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: AppColors.outline)),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right,
                                          color: AppColors.outline),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Receipt section
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 4.0, bottom: 8.0),
                                child: Text('Receipt',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink)),
                              ),
                              if (_receiptUrl != null)
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
                                              child:
                                                  Image.network(_receiptUrl!),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: AppColors.outlineVariant
                                              .withValues(alpha: 0.3)),
                                      image: DecorationImage(
                                        image: NetworkImage(_receiptUrl!),
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
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(Icons.close,
                                                color: AppColors.error),
                                            onPressed: () => setState(
                                                () => _receiptUrl = null),
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
                                )
                              else
                                GestureDetector(
                                  onTap: _isUploadingReceipt
                                      ? null
                                      : _uploadEvidence,
                                  child: Container(
                                    height: 80,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_isUploadingReceipt)
                                          const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        else ...[
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: const BoxDecoration(
                                              color: AppColors
                                                  .surfaceContainerLowest,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.receipt_long,
                                                color: AppColors.primary),
                                          ),
                                          const SizedBox(width: 16),
                                          const Text('Upload Receipt',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary)),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),

                              // Notes
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 4.0, bottom: 8.0),
                                child: Text('Notes',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                    hintText: 'Add some details (optional)...',
                                    hintStyle:
                                        TextStyle(color: AppColors.outline),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Split Breakdown
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 4.0, bottom: 12.0),
                                child: Text('Split Breakdown',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Split Method',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.outline)),
                                        const SizedBox(height: 12),
                                        Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors
                                                .surfaceContainerLowest,
                                            borderRadius:
                                                BorderRadius.circular(22),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => setState(() =>
                                                      _selectedSplitType =
                                                          ExpenseSplitType
                                                              .shares),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: _selectedSplitType ==
                                                              ExpenseSplitType
                                                                  .shares
                                                          ? AppColors
                                                              .primaryContainer
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              22),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text('Split Equally',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: _selectedSplitType ==
                                                                    ExpenseSplitType
                                                                        .shares
                                                                ? AppColors
                                                                    .onPrimaryContainer
                                                                : AppColors
                                                                    .ink)),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => setState(() =>
                                                      _selectedSplitType =
                                                          ExpenseSplitType
                                                              .exact),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: _selectedSplitType ==
                                                              ExpenseSplitType
                                                                  .exact
                                                          ? AppColors
                                                              .primaryContainer
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              22),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text('Exact Amount',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: _selectedSplitType ==
                                                                    ExpenseSplitType
                                                                        .exact
                                                                ? AppColors
                                                                    .onPrimaryContainer
                                                                : AppColors
                                                                    .ink)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_members.isNotEmpty)
                                      ExpenseSplitWidget(
                                        splitType: _selectedSplitType,
                                        members: _members,
                                        amountController: _amountController,
                                        onSplitsChanged: (splits) {
                                          setState(() {
                                            _splits = splits;
                                          });
                                        },
                                      )
                                    else
                                      const Center(
                                          child: CircularProgressIndicator()),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                color: AppColors.canvas,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _submit(context),
                    icon: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.receipt_long,
                            color: AppColors.onPrimaryContainer, size: 24),
                    label: Text(
                      widget.expenseId == null
                          ? 'Save Expense'
                          : 'Update Expense',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onPrimaryContainer),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
