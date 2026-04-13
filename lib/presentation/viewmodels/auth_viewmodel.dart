// lib/presentation/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

enum AuthState { initial, loading, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _authRepository = authRepository;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get hasError => _state == AuthState.error;

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _loginUseCase(email: email, password: password);
      _state = AuthState.authenticated;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _state = AuthState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
