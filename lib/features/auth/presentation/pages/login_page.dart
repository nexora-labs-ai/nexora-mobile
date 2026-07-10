import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../app/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../../../shared/widgets/app_button.dart';
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
  bool _obscurePassword = true;
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
    // Phải khớp Y HỆT với MEZON_REDIRECT_URI trong backend .env
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text('Welcome back', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue planning with your group',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: FormValidators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(context),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                      FormValidators.required(v, fieldName: 'Password'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Sign In',
                  isLoading: isEmailLoading,
                  onPressed: isLoading ? null : () => _submit(context),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textDisabled),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Sign in with Google',
                  isLoading: isGoogleLoading,
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() => _loadingType = LoginType.google);
                          context.read<AuthCubit>().loginWithGoogle();
                        },
                  isOutlined: true,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Sign in with Mezon',
                  isLoading: isMezonLoading,
                  isOutlined: true,
                  color: Colors.black,
                  onPressed:
                      isLoading ? null : () => _handleMezonLogin(context),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ",
                        style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
