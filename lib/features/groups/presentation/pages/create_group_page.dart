import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currencyController =
      TextEditingController(text: AppConstants.defaultCurrency);
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _currencyController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = isStart ? DateTime.now() : (_startDate ?? DateTime.now());
    final lastDate = DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date cannot be before start date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final budgetStr = _budgetController.text.trim();
    final budgetGoal = budgetStr.isNotEmpty ? double.tryParse(budgetStr) : null;

    context.read<GroupCubit>().createGroup(
          CreateGroupParams(
            name: _nameController.text.trim(),
            currency: _currencyController.text.trim().isEmpty
                ? 'USD'
                : _currencyController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            budgetGoal: budgetGoal,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE9ECE2); // Light greenish-grey background

    return BlocProvider(
      create: (_) => sl<GroupCubit>(),
      child: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupCreated) {
            context.pop();
          }
          if (state is GroupFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupLoading;
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: () => context.pop(),
              ),
              title: Row(
                children: [
                  const Icon(Icons.bubble_chart,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Nexora',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New adventure',
                              style: GoogleFonts.inter(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1C1B1F),
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gather your friends, split expenses, and track your next journey effortlessly.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF49454F),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Form Container
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
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
                                  _buildFieldLabel('Trip Name'),
                                  AppTextField(
                                    hint: "e.g. Stockholm Midsummer '24",
                                    controller: _nameController,
                                    fillColor: const Color(0xFFF7F9ED),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Trip name is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFieldLabel('Description'),
                                  AppTextField(
                                    hint: 'Tell us about the trip...',
                                    controller: _descriptionController,
                                    fillColor: const Color(0xFFF7F9ED),
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildFieldLabel('Start Date'),
                                            _buildDateSelector(
                                              context,
                                              date: _startDate,
                                              isStart: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildFieldLabel('End Date'),
                                            _buildDateSelector(
                                              context,
                                              date: _endDate,
                                              isStart: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFieldLabel('Budget Goal'),
                                  AppTextField(
                                    hint: '0.00',
                                    controller: _budgetController,
                                    fillColor: const Color(0xFFF7F9ED),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text('\$',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: const Color(0xFF2F6C00))),
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text('USD',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: AppColors.outline,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nexora AI will help you stay within this limit based on local costs.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.outline,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
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
                                      strokeWidth: 2,
                                      color: AppColors.onPrimaryContainer))
                              : const Icon(Icons.add_circle_outline,
                                  color: AppColors.onPrimaryContainer),
                          label: Text(
                            'Create Group',
                            style: GoogleFonts.inter(
                              color: AppColors.onPrimaryContainer,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimaryContainer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1C1B1F),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context,
      {required DateTime? date, required bool isStart}) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                      : 'DD/MM/YYYY',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        date != null ? AppColors.onSurface : AppColors.outline,
                    fontWeight:
                        date != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
