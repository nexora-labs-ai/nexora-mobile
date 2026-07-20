import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../app/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_card.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/mezon_login_webview.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum LoginType { none, email, google, mezon }

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginType _loadingType = LoginType.none;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loadingType = LoginType.email);
    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _handleMezonLogin(BuildContext context) async {
    const clientId = '2067865787854491648';
    const redirectUri = 'https://localhost:3002/auth/mezon/callback';
    const authUrl =
        'https://oauth2.mezon.ai/oauth2/auth?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&state=nexora123';

    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const MezonLoginWebView(
          authUrl: authUrl,
          redirectUri: redirectUri,
        ),
      ),
    );

    if (code != null && context.mounted) {
      setState(() => _loadingType = LoginType.mezon);
      context.read<AuthCubit>().loginWithMezon(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) context.go(RouteNames.dashboard);
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) => _buildScaffold(context, state),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;
    final isEmailLoading = isLoading &&
        (_loadingType == LoginType.email || _loadingType == LoginType.none);
    final isGoogleLoading = isLoading && _loadingType == LoginType.google;
    final isMezonLoading = isLoading && _loadingType == LoginType.mezon;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Nexora',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Plan together.\nPay together.',
                style: AppTextStyles.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Form Card
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email Address',
                          hint: 'name@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          hasSparkle: true,
                          validator: FormValidators.email,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(context),
                          validator: (v) =>
                              FormValidators.required(v, fieldName: 'Password'),
                        ),
                        const SizedBox(height: 32),
                        if (isEmailLoading)
                          const CircularProgressIndicator()
                        else
                          AppButton(
                            label: 'Log In',
                            color: AppColors.primaryContainer, // Lime green
                            onPressed: () => _submit(context),
                          ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.push(RouteNames.register),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                AppColors.primary, // Dark green text
                            textStyle: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text("Don't have an account? Register"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // OR Divider
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 32),

              // Social Logins
              AppButton(
                label: 'Google',
                isOutlined: true,
                isLoading: isGoogleLoading,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() => _loadingType = LoginType.google);
                        context.read<AuthCubit>().loginWithGoogle();
                      },
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Mezon', // or Apple
                isOutlined: true,
                isLoading: isMezonLoading,
                icon: const Icon(Icons.apple, size: 24),
                onPressed: isLoading ? null : () => _handleMezonLogin(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
