import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
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
            'splitType': _selectedSplitType.toApi(),
            'splits': _splits,
            'description': _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
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
          paidByUserId: currentUserId,
          categoryId: _selectedCategory ?? '',
          fundingSource: _selectedFundingSource.toApi(),
          expenseDate: _selectedDate,
          splitType: _selectedSplitType.toApi(),
          splits: _splits,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _amountController.text = formatMinorUnits(expense.amount);
            _descriptionController.text = expense.description ?? '';
            if (_categories.isEmpty) {
              _selectedCategory = expense.categoryId;
            } else {
              _selectedCategory =
                  _categories.any((c) => c.id == expense.categoryId)
                      ? expense.categoryId
                      : _categories.first.id;
            }
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
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    widget.expenseId == null ? 'Add Expense' : 'Edit Expense'),
                actions: [
                  if (widget.expenseId == null)
                    IconButton(
                      icon: _isAnalyzingReceipt
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.document_scanner),
                      tooltip: 'Scan Receipt',
                      onPressed: _isAnalyzingReceipt ? null : _scanReceipt,
                    ),
                ],
              ),
              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Title',
                              controller: _titleController,
                              hint: 'Dinner at Bún Bò Huế',
                              validator: (v) => FormValidators.required(v,
                                  fieldName: 'Title'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Amount',
                                    controller: _amountController,
                                    hint: '0',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: FormValidators.positiveAmount,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                DropdownButton<String>(
                                  value: _selectedCurrency,
                                  items: AppConstants.supportedCurrencies
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged:
                                      null, // Disabled to lock it to group currency
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Date'),
                              subtitle: Text(DateFormat('MMM dd, yyyy')
                                  .format(_selectedDate)),
                              trailing:
                                  const Icon(Icons.calendar_today_outlined),
                              contentPadding: EdgeInsets.zero,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_categories.isNotEmpty)
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                    labelText: 'Category'),
                                items: _categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Text(c.icon),
                                        const SizedBox(width: 8),
                                        Text(c.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCategory = v),
                              ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ExpenseSplitType>(
                              initialValue: _selectedSplitType,
                              decoration: const InputDecoration(
                                  labelText: 'Split Type'),
                              items: const [
                                DropdownMenuItem(
                                    value: ExpenseSplitType.shares,
                                    child: Text('By Shares')),
                                DropdownMenuItem(
                                    value: ExpenseSplitType.exact,
                                    child: Text('Exact Amount')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedSplitType = v!),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<FundingSource>(
                              initialValue: _selectedFundingSource,
                              decoration: const InputDecoration(
                                  labelText: 'Funding Source'),
                              items: const [
                                DropdownMenuItem(
                                    value: FundingSource.personal,
                                    child: Text('Personal')),
                                DropdownMenuItem(
                                    value: FundingSource.groupFund,
                                    child: Text('Group Fund')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedFundingSource = v!),
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
                              const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Description (optional)',
                              controller: _descriptionController,
                              hint: 'Notes about this expense',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              label: 'Save Expense',
                              isLoading: isLoading,
                              onPressed:
                                  isLoading ? null : () => _submit(context),
                            ),
                          ],
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
