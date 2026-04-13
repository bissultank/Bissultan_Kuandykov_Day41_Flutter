// test/unit/auth_viewmodel_test.dart
//
// Тестируем AuthViewModel изолированно через MockAuthRepository.
// Паттерн AAA: Arrange → Act → Assert
// Реальный Firebase/HTTP не вызывается — тесты быстрые и стабильные.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasks_app/domain/entities/user.dart';
import 'package:tasks_app/domain/usecases/login_usecase.dart';
import 'package:tasks_app/presentation/viewmodels/auth_viewmodel.dart';
import '../mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginUseCase loginUseCase;
  late AuthViewModel viewModel;

  const fakeUser = User(
    id: 'user_001',
    email: 'test@mail.com',
    token: 'jwt_abc',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
    viewModel = AuthViewModel(
      loginUseCase: loginUseCase,
      authRepository: mockAuthRepository,
    );
  });

  group('AuthViewModel — login', () {
    test('успешный логин меняет state на authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.login(
            email: 'test@mail.com',
            password: '123456',
          )).thenAnswer((_) async => fakeUser);

      expect(viewModel.state, AuthState.initial);
      expect(viewModel.isLoading, false);

      // Act
      await viewModel.login('test@mail.com', '123456');

      // Assert
      expect(viewModel.state, AuthState.authenticated);
      expect(viewModel.isAuthenticated, true);
      expect(viewModel.currentUser?.email, 'test@mail.com');
      expect(viewModel.hasError, false);
      expect(viewModel.isLoading, false);

      verify(() => mockAuthRepository.login(
            email: 'test@mail.com',
            password: '123456',
          )).called(1);
    });

    test('ошибка логина меняет state на error', () async {
      // Arrange
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      // Act
      await viewModel.login('bad@mail.com', 'wrong');

      // Assert
      expect(viewModel.state, AuthState.error);
      expect(viewModel.hasError, true);
      expect(viewModel.errorMessage, 'Invalid credentials');
      expect(viewModel.isAuthenticated, false);
      expect(viewModel.currentUser, isNull);
    });

    test('во время загрузки isLoading = true', () async {
      // Arrange: искусственная задержка
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return fakeUser;
      });

      final states = <bool>[];
      viewModel.addListener(() => states.add(viewModel.isLoading));

      // Act
      await viewModel.login('test@mail.com', '123456');

      // Assert: сначала true (loading), потом false (done)
      expect(states, containsAll([true, false]));
    });

    test('пустой email бросает ArgumentError до вызова repository', () async {
      // Act
      await viewModel.login('', '123456');

      // Assert
      expect(viewModel.hasError, true);
      // Repository НЕ должен был вызываться
      verifyNever(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });
  });

  group('AuthViewModel — logout', () {
    test('logout сбрасывает state и пользователя', () async {
      // Arrange: сначала логинимся
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => fakeUser);
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await viewModel.login('test@mail.com', '123456');
      expect(viewModel.isAuthenticated, true);

      // Act
      await viewModel.logout();

      // Assert
      expect(viewModel.state, AuthState.initial);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isAuthenticated, false);
      verify(() => mockAuthRepository.logout()).called(1);
    });
  });
}
