// lib/domain/usecases/login_usecase.dart

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> call({required String email, required String password}) {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password must not be empty');
    }
    return _repository.login(email: email, password: password);
  }
}
