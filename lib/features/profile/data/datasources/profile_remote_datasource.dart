import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<UserModel> uploadAvatar(File file);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.patch(
      ApiEndpoints.me,
      data: data,
    );
    final responseData = response.data['data'] ?? response.data;
    return UserModel.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<UserModel> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.me}/avatar',
      data: formData,
    );
    final responseData = response.data['data'] ?? response.data;
    return UserModel.fromJson(responseData as Map<String, dynamic>);
  }
}
