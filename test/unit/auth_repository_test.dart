// test/unit/auth_repository_test.dart
//
// Тестируем AuthRepositoryImpl изолированно:
// - ApiClient мокируется → нет реальных HTTP-запросов
// - LocalStorage мокируется → нет реальных файлов/SharedPrefs
// - Паттерн AAA: Arrange → Act → Assert

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasks_app/data/models/user_dto.dart';
import 'package:tasks_app/data/repositories/auth_repository_impl.dart';
import '../mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late MockLocalStorage mockLocalStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockLocalStorage = MockLocalStorage();
    repository = AuthRepositoryImpl(
      apiClient: mockApiClient,
      localStorage: mockLocalStorage,
    );
  });

  group('AuthRepository — login', () {
    const email = 'test@mail.com';
    const password = '123456';
    const fakeUserDto = UserDto(
      id: 'user_1',
      email: email,
      token: 'jwt_token_xyz',
    );

    test('успешный логин сохраняет токен и возвращает User', () async {
      // Arrange
      when(() => mockApiClient.login(email, password))
          .thenAnswer((_) async => fakeUserDto);
      when(() => mockLocalStorage.saveToken(any()))
          .thenAnswer((_) async {});

      // Act
      final user = await repository.login(email: email, password: password);

      // Assert
      expect(user.email, email);
      expect(user.token, 'jwt_token_xyz');
      expect(user.id, 'user_1');

      // Проверяем, что ApiClient был вызван с правильными параметрами
      verify(() => mockApiClient.login(email, password)).called(1);

      // Проверяем, что токен был сохранён в хранилище
      verify(() => mockLocalStorage.saveToken('jwt_token_xyz')).called(1);
    });

    test('ошибка логина НЕ сохраняет токен', () async {
      // Arrange
      when(() => mockApiClient.login(email, 'wrong_pass'))
          .thenThrow(Exception('Invalid credentials'));

      // Act + Assert
      expect(
        () => repository.login(email: email, password: 'wrong_pass'),
        throwsException,
      );

      // Токен НЕ должен быть сохранён
      verifyNever(() => mockLocalStorage.saveToken(any()));
    });
  });

  group('AuthRepository — logout', () {
    test('logout вызывает clearToken', () async {
      // Arrange
      when(() => mockLocalStorage.clearToken()).thenAnswer((_) async {});

      // Act
      await repository.logout();

      // Assert
      verify(() => mockLocalStorage.clearToken()).called(1);
    });
  });

  group('AuthRepository — isLoggedIn', () {
    test('возвращает true если токен есть', () async {
      // Arrange
      when(() => mockLocalStorage.getToken())
          .thenAnswer((_) async => 'valid_token');

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, true);
    });

    test('возвращает false если токен null', () async {
      // Arrange
      when(() => mockLocalStorage.getToken()).thenAnswer((_) async => null);

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, false);
    });

    test('возвращает false если токен пустой', () async {
      // Arrange
      when(() => mockLocalStorage.getToken()).thenAnswer((_) async => '');

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, false);
    });
  });
}
