// lib/data/datasources/api_client.dart

import 'dart:convert';
import '../models/task_dto.dart';
import '../models/user_dto.dart';

/// Abstract API Client — интерфейс для мокирования в тестах
abstract class ApiClient {
  Future<UserDto> login(String email, String password);
  Future<List<TaskDto>> getTasks(String token);
  Future<TaskDto> createTask(String token, String title);
  Future<void> deleteTask(String token, String id);
}

/// Fake JSON responses — статические ответы для локальной заглушки
class FakeApiResponses {
  static const String loginSuccess = '''
  {
    "id": "user_001",
    "email": "test@mail.com",
    "token": "fake_jwt_token_abc123"
  }
  ''';

  static const String tasksJson = '''
  [
    {"id": "task_1", "title": "Купить продукты", "is_completed": false},
    {"id": "task_2", "title": "Почитать документацию Flutter", "is_completed": true},
    {"id": "task_3", "title": "Написать тесты", "is_completed": false}
  ]
  ''';

  static Map<String, dynamic> taskCreated(String id, String title) => {
        'id': id,
        'title': title,
        'is_completed': false,
      };
}

/// Fake API Client — заглушка с фиксированными JSON-ответами
/// Используется вместо реального HTTP-клиента в integration-тестах
class FakeApiClient implements ApiClient {
  final List<TaskDto> _tasks = [];
  bool _initialized = false;
  int _taskCounter = 100;

  FakeApiClient() {
    // Инициализируем задачами из статического JSON
    final json = jsonDecode(FakeApiResponses.tasksJson) as List;
    _tasks.addAll(json.map((e) => TaskDto.fromJson(e as Map<String, dynamic>)));
    _initialized = true;
  }

  @override
  Future<UserDto> login(String email, String password) async {
    // Имитируем задержку сети
    await Future.delayed(const Duration(milliseconds: 100));

    if (email == 'test@mail.com' && password == '123456') {
      return UserDto.fromJson(
        jsonDecode(FakeApiResponses.loginSuccess) as Map<String, dynamic>,
      );
    }
    throw Exception('Неверный логин или пароль');
  }

  @override
  Future<List<TaskDto>> getTasks(String token) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _validateToken(token);
    return List.from(_tasks);
  }

  @override
  Future<TaskDto> createTask(String token, String title) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _validateToken(token);

    final newTask = TaskDto.fromJson(
      FakeApiResponses.taskCreated('task_${++_taskCounter}', title),
    );
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<void> deleteTask(String token, String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _validateToken(token);
    _tasks.removeWhere((t) => t.id == id);
  }

  void _validateToken(String token) {
    if (token.isEmpty) throw Exception('Нет авторизации');
  }

  void reset() {
    _tasks.clear();
    final json = jsonDecode(FakeApiResponses.tasksJson) as List;
    _tasks.addAll(json.map((e) => TaskDto.fromJson(e as Map<String, dynamic>)));
  }
}
