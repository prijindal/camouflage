import "dart:convert";

import "package:dio/dio.dart";

import "../helpers/logger.dart";

class RegisterResponse {
  String username;
  String token;

  RegisterResponse({required this.username, required this.token});
}

class UserResponse {
  String username;
  String publicKey;

  UserResponse({required this.username, required this.publicKey});
}

class ApiHttpClient {
  final dio = Dio(BaseOptions(
    baseUrl: "http://localhost:3000",
    headers: {
      "Content-Type": "application/json",
    },
  ));

  static final ApiHttpClient instance = ApiHttpClient();

  Future<void> health() async {
    try {
      await dio.get<dynamic>("/api/health");
    } on DioException catch (e) {
      AppLogger.instance.e(e.response);
      rethrow;
    }
  }

  Future<RegisterResponse> register({
    required String username,
    required String master_hash,
    required String public_key,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        "/api/users/register",
        data: jsonEncode({
          "username": username,
          "master_hash": master_hash,
          "public_key": public_key,
        }),
      );
      return RegisterResponse(
        username: response.data["username"] as String,
        token: response.data["token"] as String,
      );
    } on DioException catch (e) {
      AppLogger.instance.e(e.response);
      rethrow;
    }
  }

  Future<UserResponse> getUser({
    required String username,
    required String token,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        "/api/users/$username",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      return UserResponse(
        username: response.data["username"] as String,
        publicKey: response.data["public_key"] as String,
      );
    } on DioException catch (e) {
      AppLogger.instance.e(e.response);
      rethrow;
    }
  }

  Future<UserResponse> getMe({
    required String token,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        "/api/users/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      return UserResponse(
        username: response.data["username"] as String,
        publicKey: response.data["public_key"] as String,
      );
    } on DioException catch (e) {
      AppLogger.instance.e(e.response);
      rethrow;
    }
  }

  Future<void> logout({
    required String token,
  }) async {
    try {
      await dio.get<dynamic>(
        "/api/users/logout",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      AppLogger.instance.e(e.response);
      rethrow;
    }
  }
}
