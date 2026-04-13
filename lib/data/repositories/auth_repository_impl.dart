// lib/data/repositories/auth_repository_impl.dart

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api_client.dart';
import '../datasources/local_storage.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  @override
  Future<User> login({required String email, required String password}) async {
    final userDto = await _apiClient.login(email, password);
    // Сохраняем токен локально
    await _localStorage.saveToken(userDto.token);
    return userDto.toDomain();
  }

  @override
  Future<void> logout() async {
    await _localStorage.clearToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _localStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
