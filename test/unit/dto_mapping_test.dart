// test/unit/dto_mapping_test.dart
//
// Тестируем маппинг DTO ↔ Domain без моков — чистая логика.
// Также тестируем FakeApiClient как fake-сервер с фиксированными JSON-ответами.

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasks_app/data/datasources/api_client.dart';
import 'package:tasks_app/data/models/task_dto.dart';
import 'package:tasks_app/data/models/user_dto.dart';
import 'package:tasks_app/domain/entities/task.dart';

void main() {
  group('TaskDto', () {
    test('fromJson корректно парсит JSON', () {
      final json = {
        'id': 'task_1',
        'title': 'Buy groceries',
        'is_completed': false,
      };
      final dto = TaskDto.fromJson(json);
      expect(dto.id, 'task_1');
      expect(dto.title, 'Buy groceries');
      expect(dto.isCompleted, false);
    });

    test('fromJson использует false если is_completed отсутствует', () {
      final dto = TaskDto.fromJson({'id': 'task_1', 'title': 'Test'});
      expect(dto.isCompleted, false);
    });

    test('toDomain возвращает корректный Task', () {
      const dto = TaskDto(id: 'task_1', title: 'Test', isCompleted: true);
      final task = dto.toDomain();
      expect(task.id, 'task_1');
      expect(task.isCompleted, true);
    });

    test('round-trip: Task -> DTO -> Task сохраняет данные', () {
      const original = Task(id: 't1', title: 'Round trip', isCompleted: true);
      final restored = original.toDto().toDomain();
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.isCompleted, original.isCompleted);
    });
  });

  group('UserDto', () {
    test('fromJson корректно парсит JSON', () {
      final json = {'id': 'user_1', 'email': 'test@mail.com', 'token': 'jwt_xyz'};
      final dto = UserDto.fromJson(json);
      expect(dto.token, 'jwt_xyz');
    });

    test('toDomain возвращает корректный User', () {
      const dto = UserDto(id: 'u1', email: 'a@b.com', token: 'tok');
      final user = dto.toDomain();
      expect(user.email, 'a@b.com');
    });
  });

  group('FakeApiClient — static JSON responses (fake-server)', () {
    test('tasksJson содержит 3 валидные задачи', () {
      final list = jsonDecode(FakeApiResponses.tasksJson) as List;
      expect(list.length, 3);
      final first = TaskDto.fromJson(list.first as Map<String, dynamic>);
      expect(first.id, 'task_1');
    });

    test('loginSuccess содержит валидный токен', () {
      final json = jsonDecode(FakeApiResponses.loginSuccess) as Map<String, dynamic>;
      expect(json['token'], isNotEmpty);
    });

    test('taskCreated генерирует правильный объект', () {
      final json = FakeApiResponses.taskCreated('task_new', 'Test Task');
      final dto = TaskDto.fromJson(json);
      expect(dto.title, 'Test Task');
      expect(dto.isCompleted, false);
    });
  });

  group('FakeApiClient — in-memory server behavior', () {
    late FakeApiClient fakeApi;
    const token = 'fake_jwt_token_abc123';

    setUp(() => fakeApi = FakeApiClient());

    test('login с правильными данными возвращает пользователя', () async {
      final user = await fakeApi.login('test@mail.com', '123456');
      expect(user.token, token);
    });

    test('login с неверным паролем выбрасывает исключение', () {
      expect(() => fakeApi.login('test@mail.com', 'wrong'), throwsException);
    });

    test('getTasks возвращает 3 задачи', () async {
      final tasks = await fakeApi.getTasks(token);
      expect(tasks.length, 3);
    });

    test('createTask добавляет задачу', () async {
      await fakeApi.createTask(token, 'Brand New Task');
      final tasks = await fakeApi.getTasks(token);
      expect(tasks.length, 4);
      expect(tasks.last.title, 'Brand New Task');
    });

    test('deleteTask удаляет задачу', () async {
      await fakeApi.deleteTask(token, 'task_1');
      final tasks = await fakeApi.getTasks(token);
      expect(tasks.length, 2);
      expect(tasks.any((t) => t.id == 'task_1'), false);
    });

    test('пустой токен вызывает Unauthorized', () {
      expect(() => fakeApi.getTasks(''), throwsException);
    });
  });
}
