import 'package:dio/dio.dart';

/// Unwraps the standard backend response format: { success, data, ... }
class ResponseWrapperInterceptor extends Interceptor {
  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data')) {
        response.data = map['data'];
      }
    }
    super.onResponse(response, handler);
  }
}
