import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/socket/socket_service.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import 'bindings/injection_container.dart';
import 'router/app_router.dart';

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 baseline
      minTextAdapt: true,
      builder: (_, __) => BlocProvider<AuthCubit>.value(
        value: sl<AuthCubit>(),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              sl<SocketService>().connect();
            } else if (state is AuthUnauthenticated) {
              sl<SocketService>().disconnect();
            }
          },
          child: MaterialApp.router(
            title: 'Nexora',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}
