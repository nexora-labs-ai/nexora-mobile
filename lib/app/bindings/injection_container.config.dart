// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/interceptors/auth_interceptor.dart' as _i1026;
import '../../core/interceptors/retry_interceptor.dart' as _i962;
import '../../core/network/dio_client.dart' as _i571;
import '../../core/notification/fcm_service.dart' as _i3;
import '../../core/socket/event_dispatcher.dart' as _i214;
import '../../core/socket/socket_service.dart' as _i934;
import '../../core/storage/hive_storage.dart' as _i526;
import '../../core/storage/secure_storage.dart' as _i108;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i504;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/presentation/bloc/chat_bloc.dart' as _i65;
import '../../features/expenses/data/datasources/expense_local_datasource.dart'
    as _i328;
import '../../features/expenses/data/datasources/expense_remote_datasource.dart'
    as _i848;
import '../../features/expenses/data/repositories/expense_repository_impl.dart'
    as _i786;
import '../../features/expenses/domain/repositories/expense_repository.dart'
    as _i939;
import '../../features/expenses/domain/usecases/create_expense_usecase.dart'
    as _i188;
import '../../features/expenses/domain/usecases/delete_expense_usecase.dart'
    as _i172;
import '../../features/expenses/domain/usecases/get_expenses_usecase.dart'
    as _i821;
import '../../features/expenses/presentation/cubit/expense_cubit.dart' as _i230;
import '../../features/groups/data/repositories/group_repository_impl.dart'
    as _i335;
import '../../features/groups/domain/repositories/group_repository.dart'
    as _i324;
import '../../features/groups/domain/usecases/create_group_usecase.dart'
    as _i192;
import '../../features/groups/domain/usecases/get_groups_usecase.dart' as _i264;
import '../../features/groups/presentation/cubit/group_cubit.dart' as _i746;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i526.HiveStorage>(() => _i526.HiveStorage());
    gh.singleton<_i108.SecureStorage>(() => _i108.SecureStorage());
    gh.singleton<_i3.FcmService>(
        () => _i3.FcmService(gh<_i892.FirebaseMessaging>()));
    gh.singleton<_i934.SocketService>(
        () => _i934.SocketService(gh<_i108.SecureStorage>()));
    gh.factory<_i962.RetryInterceptor>(
        () => _i962.RetryInterceptor(maxRetries: gh<int>()));
    gh.factory<_i992.AuthLocalDatasource>(
        () => _i992.AuthLocalDatasourceImpl(gh<_i108.SecureStorage>()));
    gh.factory<_i65.ChatBloc>(() => _i65.ChatBloc(gh<InvalidType>()));
    gh.factory<_i746.GroupCubit>(() => _i746.GroupCubit(
          gh<InvalidType>(),
          gh<InvalidType>(),
          gh<InvalidType>(),
        ));
    gh.factory<_i117.AuthCubit>(() => _i117.AuthCubit(
          gh<InvalidType>(),
          gh<InvalidType>(),
          gh<InvalidType>(),
        ));
    gh.factory<_i1026.AuthInterceptor>(() => _i1026.AuthInterceptor(
          gh<_i108.SecureStorage>(),
          gh<_i361.Dio>(),
        ));
    gh.factory<_i328.ExpenseLocalDatasource>(
        () => _i328.ExpenseLocalDatasourceImpl(gh<_i526.HiveStorage>()));
    gh.factory<_i230.ExpenseCubit>(() => _i230.ExpenseCubit(
          gh<InvalidType>(),
          gh<InvalidType>(),
          gh<InvalidType>(),
        ));
    gh.singleton<_i214.EventDispatcher>(
        () => _i214.EventDispatcher(gh<_i934.SocketService>()));
    gh.singleton<_i571.DioClient>(() => _i571.DioClient(
          gh<_i1026.AuthInterceptor>(),
          gh<_i962.RetryInterceptor>(),
        ));
    gh.factory<_i420.ChatRepository>(() => _i504.ChatRepositoryImpl(
          gh<_i571.DioClient>(),
          gh<_i214.EventDispatcher>(),
        ));
    gh.factory<_i324.GroupRepository>(
        () => _i335.GroupRepositoryImpl(gh<_i571.DioClient>()));
    gh.factory<_i848.ExpenseRemoteDatasource>(
        () => _i848.ExpenseRemoteDatasourceImpl(gh<_i571.DioClient>()));
    gh.factory<_i939.ExpenseRepository>(() => _i786.ExpenseRepositoryImpl(
          gh<_i848.ExpenseRemoteDatasource>(),
          gh<_i328.ExpenseLocalDatasource>(),
        ));
    gh.factory<_i161.AuthRemoteDatasource>(
        () => _i161.AuthRemoteDatasourceImpl(gh<_i571.DioClient>()));
    gh.factory<_i188.CreateExpenseUseCase>(
        () => _i188.CreateExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i172.DeleteExpenseUseCase>(
        () => _i172.DeleteExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i821.GetExpensesUseCase>(
        () => _i821.GetExpensesUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i192.CreateGroupUseCase>(
        () => _i192.CreateGroupUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i264.GetGroupsUseCase>(
        () => _i264.GetGroupsUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i264.GetGroupDetailUseCase>(
        () => _i264.GetGroupDetailUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          gh<_i161.AuthRemoteDatasource>(),
          gh<_i992.AuthLocalDatasource>(),
        ));
    gh.factory<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i48.LogoutUseCase>(
        () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    return this;
  }
}
