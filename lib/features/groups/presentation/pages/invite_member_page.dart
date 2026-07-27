import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<GroupCubit>().inviteMember(
          groupId: widget.groupId,
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCubit, GroupState>(
      listener: (context, state) {
        if (state is GroupMemberInvited) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invitation sent successfully'),
                backgroundColor: AppColors.primaryContainer),
          );
          context.pop();
        }
        if (state is GroupFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is GroupLoading;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Member',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Invite someone to join this group.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Email or Username',
                  controller: _emailController,
                  hint: 'user@example.com or username',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Cannot be empty';
                    if (!val.contains('@') &&
                        !RegExp(r'^[a-z0-9_]+$').hasMatch(val)) {
                      return 'Invalid email or username format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Send Invitation',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : () => _submit(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
