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
import '../../features/activity/presentation/cubit/activity_cubit.dart'
    as _i883;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/login_with_google_usecase.dart'
    as _i57;
import '../../features/auth/domain/usecases/login_with_mezon_usecase.dart'
    as _i320;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i504;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/presentation/bloc/chat_bloc.dart' as _i65;
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart'
    as _i24;
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
import '../../features/expenses/domain/usecases/get_categories_usecase.dart'
    as _i676;
import '../../features/expenses/domain/usecases/get_expense_by_id_usecase.dart'
    as _i844;
import '../../features/expenses/domain/usecases/get_expenses_usecase.dart'
    as _i821;
import '../../features/expenses/domain/usecases/get_group_balance_usecase.dart'
    as _i416;
import '../../features/expenses/domain/usecases/update_expense_usecase.dart'
    as _i721;
import '../../features/expenses/presentation/cubit/expense_cubit.dart' as _i230;
import '../../features/group_chat/data/repositories/group_chat_repository_impl.dart'
    as _i30;
import '../../features/group_chat/domain/repositories/group_chat_repository.dart'
    as _i348;
import '../../features/group_chat/presentation/bloc/group_chat_bloc.dart'
    as _i90;
import '../../features/groups/data/repositories/group_repository_impl.dart'
    as _i335;
import '../../features/groups/domain/repositories/group_repository.dart'
    as _i324;
import '../../features/groups/domain/usecases/create_group_usecase.dart'
    as _i192;
import '../../features/groups/domain/usecases/get_group_members_usecase.dart'
    as _i869;
import '../../features/groups/domain/usecases/get_groups_usecase.dart' as _i264;
import '../../features/groups/domain/usecases/invite_member_usecase.dart'
    as _i479;
import '../../features/groups/domain/usecases/kick_member_usecase.dart'
    as _i304;
import '../../features/groups/domain/usecases/leave_group_usecase.dart'
    as _i169;
import '../../features/groups/domain/usecases/update_group_usecase.dart'
    as _i363;
import '../../features/groups/domain/usecases/update_member_role_usecase.dart'
    as _i866;
import '../../features/groups/domain/usecases/upload_group_avatar_usecase.dart'
    as _i897;
import '../../features/groups/presentation/cubit/group_cubit.dart' as _i746;
import '../../features/groups/presentation/cubit/group_fund_cubit.dart'
    as _i819;
import '../../features/itinerary/data/repositories/itinerary_repository.dart'
    as _i1069;
import '../../features/itinerary/presentation/blocs/itinerary_cubit.dart'
    as _i122;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i201;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i563;
import '../../features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i405;
import '../../features/profile/data/datasources/profile_remote_datasource.dart'
    as _i327;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/update_profile_usecase.dart'
    as _i478;
import '../../features/profile/domain/usecases/upload_avatar_usecase.dart'
    as _i658;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../../features/recommendations/data/datasources/recommendations_remote_datasource.dart'
    as _i185;
import '../../features/recommendations/data/repositories/recommendations_repository_impl.dart'
    as _i201;
import '../../features/recommendations/domain/repositories/recommendations_repository.dart'
    as _i373;
import '../../features/recommendations/presentation/bloc/recommendations_bloc.dart'
    as _i1016;
import '../../features/settlements/data/datasources/settlement_remote_datasource.dart'
    as _i169;
import '../../features/settlements/data/repositories/settlement_repository_impl.dart'
    as _i256;
import '../../features/settlements/domain/repositories/settlement_repository.dart'
    as _i472;
import '../../features/settlements/presentation/bloc/settlement_bloc.dart'
    as _i1072;
import 'register_module.dart' as _i291;

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
    final registerModule = _$RegisterModule();
    gh.factory<_i962.RetryInterceptor>(() => _i962.RetryInterceptor());
    gh.factory<_i883.ActivityCubit>(() => _i883.ActivityCubit());
    gh.singleton<_i526.HiveStorage>(() => _i526.HiveStorage());
    gh.singleton<_i108.SecureStorage>(() => _i108.SecureStorage());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => registerModule.firebaseMessaging);
    gh.lazySingleton<_i3.FcmService>(
        () => _i3.FcmService(gh<_i892.FirebaseMessaging>()));
    gh.singleton<_i934.SocketService>(
        () => _i934.SocketService(gh<_i108.SecureStorage>()));
    gh.factory<_i992.AuthLocalDatasource>(
        () => _i992.AuthLocalDatasourceImpl(gh<_i108.SecureStorage>()));
    gh.factory<_i1026.AuthInterceptor>(() => _i1026.AuthInterceptor(
          gh<_i108.SecureStorage>(),
          gh<_i361.Dio>(),
        ));
    gh.factory<_i328.ExpenseLocalDatasource>(
        () => _i328.ExpenseLocalDatasourceImpl(gh<_i526.HiveStorage>()));
    gh.singleton<_i214.EventDispatcher>(
        () => _i214.EventDispatcher(gh<_i934.SocketService>()));
    gh.singleton<_i571.DioClient>(() => _i571.DioClient(
          gh<_i1026.AuthInterceptor>(),
          gh<_i962.RetryInterceptor>(),
        ));
    gh.factory<_i348.GroupChatRepository>(() => _i30.GroupChatRepositoryImpl(
          gh<_i571.DioClient>(),
          gh<_i214.EventDispatcher>(),
        ));
    gh.factory<_i420.ChatRepository>(() => _i504.ChatRepositoryImpl(
          gh<_i571.DioClient>(),
          gh<_i214.EventDispatcher>(),
        ));
    gh.factory<_i324.GroupRepository>(
        () => _i335.GroupRepositoryImpl(gh<_i571.DioClient>()));
    gh.lazySingleton<_i327.ProfileRemoteDataSource>(
        () => _i327.ProfileRemoteDataSourceImpl(gh<_i571.DioClient>()));
    gh.factory<_i848.ExpenseRemoteDatasource>(
        () => _i848.ExpenseRemoteDatasourceImpl(gh<_i571.DioClient>()));
    gh.factory<_i1069.ItineraryRepository>(
        () => _i1069.ItineraryRepository(gh<_i571.DioClient>()));
    gh.factory<_i563.NotificationsRepository>(
        () => _i201.NotificationsRepositoryImpl(gh<_i571.DioClient>()));
    gh.factory<_i939.ExpenseRepository>(() => _i786.ExpenseRepositoryImpl(
          gh<_i848.ExpenseRemoteDatasource>(),
          gh<_i328.ExpenseLocalDatasource>(),
        ));
    gh.factory<_i161.AuthRemoteDatasource>(
        () => _i161.AuthRemoteDatasourceImpl(gh<_i571.DioClient>()));
    gh.factory<_i169.SettlementRemoteDatasource>(
        () => _i169.SettlementRemoteDatasourceImpl(gh<_i571.DioClient>()));
    gh.lazySingleton<_i185.RecommendationsRemoteDataSource>(
        () => _i185.RecommendationsRemoteDataSourceImpl(gh<_i571.DioClient>()));
    gh.factory<_i90.GroupChatBloc>(
        () => _i90.GroupChatBloc(gh<_i348.GroupChatRepository>()));
    gh.factory<_i472.SettlementRepository>(() =>
        _i256.SettlementRepositoryImpl(gh<_i169.SettlementRemoteDatasource>()));
    gh.factory<_i405.NotificationsCubit>(() => _i405.NotificationsCubit(
          gh<_i563.NotificationsRepository>(),
          gh<_i324.GroupRepository>(),
        ));
    gh.lazySingleton<_i894.ProfileRepository>(
        () => _i334.ProfileRepositoryImpl(gh<_i327.ProfileRemoteDataSource>()));
    gh.factory<_i122.ItineraryCubit>(
        () => _i122.ItineraryCubit(gh<_i1069.ItineraryRepository>()));
    gh.factory<_i188.CreateExpenseUseCase>(
        () => _i188.CreateExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i172.DeleteExpenseUseCase>(
        () => _i172.DeleteExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i676.GetCategoriesUseCase>(
        () => _i676.GetCategoriesUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i821.GetExpensesUseCase>(
        () => _i821.GetExpensesUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i844.GetExpenseByIdUseCase>(
        () => _i844.GetExpenseByIdUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i416.GetGroupBalanceUseCase>(
        () => _i416.GetGroupBalanceUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i721.UpdateExpenseUseCase>(
        () => _i721.UpdateExpenseUseCase(gh<_i939.ExpenseRepository>()));
    gh.factory<_i192.CreateGroupUseCase>(
        () => _i192.CreateGroupUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i264.GetGroupsUseCase>(
        () => _i264.GetGroupsUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i264.GetGroupDetailUseCase>(
        () => _i264.GetGroupDetailUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i869.GetGroupMembersUseCase>(
        () => _i869.GetGroupMembersUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i479.InviteMemberUseCase>(
        () => _i479.InviteMemberUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i304.KickMemberUseCase>(
        () => _i304.KickMemberUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i169.LeaveGroupUseCase>(
        () => _i169.LeaveGroupUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i363.UpdateGroupUseCase>(
        () => _i363.UpdateGroupUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i866.UpdateMemberRoleUseCase>(
        () => _i866.UpdateMemberRoleUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i897.UploadGroupAvatarUseCase>(
        () => _i897.UploadGroupAvatarUseCase(gh<_i324.GroupRepository>()));
    gh.factory<_i819.GroupFundCubit>(
        () => _i819.GroupFundCubit(gh<_i324.GroupRepository>()));
    gh.factory<_i230.ExpenseCubit>(() => _i230.ExpenseCubit(
          gh<_i821.GetExpensesUseCase>(),
          gh<_i188.CreateExpenseUseCase>(),
          gh<_i172.DeleteExpenseUseCase>(),
          gh<_i676.GetCategoriesUseCase>(),
          gh<_i844.GetExpenseByIdUseCase>(),
          gh<_i721.UpdateExpenseUseCase>(),
          gh<_i416.GetGroupBalanceUseCase>(),
        ));
    gh.factory<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl(
          gh<_i161.AuthRemoteDatasource>(),
          gh<_i992.AuthLocalDatasource>(),
        ));
    gh.factory<_i24.DashboardCubit>(() => _i24.DashboardCubit(
          gh<_i324.GroupRepository>(),
          gh<_i472.SettlementRepository>(),
        ));
    gh.factory<_i746.GroupCubit>(() => _i746.GroupCubit(
          gh<_i264.GetGroupsUseCase>(),
          gh<_i264.GetGroupDetailUseCase>(),
          gh<_i192.CreateGroupUseCase>(),
          gh<_i479.InviteMemberUseCase>(),
          gh<_i869.GetGroupMembersUseCase>(),
          gh<_i169.LeaveGroupUseCase>(),
          gh<_i304.KickMemberUseCase>(),
          gh<_i866.UpdateMemberRoleUseCase>(),
          gh<_i363.UpdateGroupUseCase>(),
          gh<_i897.UploadGroupAvatarUseCase>(),
        ));
    gh.factory<_i1072.SettlementBloc>(() => _i1072.SettlementBloc(
          gh<_i472.SettlementRepository>(),
          gh<_i416.GetGroupBalanceUseCase>(),
        ));
    gh.factory<_i17.GetCurrentUserUseCase>(
        () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i188.LoginUseCase>(
        () => _i188.LoginUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i57.LoginWithGoogleUseCase>(
        () => _i57.LoginWithGoogleUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i320.LoginWithMezonUseCase>(
        () => _i320.LoginWithMezonUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i48.LogoutUseCase>(
        () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()));
    gh.factory<_i941.RegisterUseCase>(
        () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i373.RecommendationsRepository>(
        () => _i201.RecommendationsRepositoryImpl(
              gh<_i185.RecommendationsRemoteDataSource>(),
              gh<_i214.EventDispatcher>(),
            ));
    gh.lazySingleton<_i117.AuthCubit>(() => _i117.AuthCubit(
          gh<_i188.LoginUseCase>(),
          gh<_i320.LoginWithMezonUseCase>(),
          gh<_i941.RegisterUseCase>(),
          gh<_i48.LogoutUseCase>(),
          gh<_i17.GetCurrentUserUseCase>(),
          gh<_i57.LoginWithGoogleUseCase>(),
        ));
    gh.lazySingleton<_i478.UpdateProfileUseCase>(
        () => _i478.UpdateProfileUseCase(gh<_i894.ProfileRepository>()));
    gh.lazySingleton<_i658.UploadAvatarUseCase>(
        () => _i658.UploadAvatarUseCase(gh<_i894.ProfileRepository>()));
    gh.factory<_i36.ProfileCubit>(() => _i36.ProfileCubit(
          gh<_i478.UpdateProfileUseCase>(),
          gh<_i658.UploadAvatarUseCase>(),
          gh<_i117.AuthCubit>(),
        ));
    gh.factory<_i1016.RecommendationsBloc>(() =>
        _i1016.RecommendationsBloc(gh<_i373.RecommendationsRepository>()));
    gh.factory<_i65.ChatBloc>(() => _i65.ChatBloc(
          gh<_i420.ChatRepository>(),
          gh<_i117.AuthCubit>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
