import "dart:convert";

import "package:dio/dio.dart";

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

  Future<RegisterResponse> register({
    required String username,
    required String master_hash,
    required String public_key,
  }) async {
    try {
      final response = await dio.post(
        "/api/users/register",
        data: jsonEncode({
          "username": username,
          "master_hash": master_hash,
          "public_key": public_key,
        }),
      );
      return RegisterResponse(
        username: response.data["username"],
        token: response.data["token"],
      );
    } on DioException catch (e) {
      print(e.response);
      rethrow;
    }
  }

  Future<UserResponse> getUser({
    required String username,
    required String token,
  }) async {
    try {
      final response = await dio.get(
        "/api/users/$username",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      return UserResponse(
        username: response.data["username"],
        publicKey: response.data["public_key"],
      );
    } on DioException catch (e) {
      print(e.response);
      rethrow;
    }
  }
}
