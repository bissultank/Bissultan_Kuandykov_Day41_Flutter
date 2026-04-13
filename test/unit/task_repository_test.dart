// test/unit/task_repository_test.dart
//
// Мокируем ApiClient и LocalStorage → нет реальных HTTP запросов.
// TaskRepositoryImpl тестируется изолированно от всех внешних систем.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasks_app/data/models/task_dto.dart';
import 'package:tasks_app/data/repositories/task_repository_impl.dart';
import '../mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late MockLocalStorage mockLocalStorage;
  late TaskRepositoryImpl repository;

  const fakeToken = 'fake_jwt_token';

  final fakeDtos = [
    const TaskDto(id: 'task_1', title: 'Buy groceries', isCompleted: false),
    const TaskDto(id: 'task_2', title: 'Read Flutter docs', isCompleted: true),
  ];

  setUp(() {
    mockApiClient = MockApiClient();
    mockLocalStorage = MockLocalStorage();

    // По умолчанию токен существует
    when(() => mockLocalStorage.getToken())
        .thenAnswer((_) async => fakeToken);

    repository = TaskRepositoryImpl(
      apiClient: mockApiClient,
      localStorage: mockLocalStorage,
    );
  });

  group('TaskRepository — getTasks', () {
    test('возвращает список задач из API', () async {
      // Arrange
      when(() => mockApiClient.getTasks(fakeToken))
          .thenAnswer((_) async => fakeDtos);

      // Act
      final tasks = await repository.getTasks();

      // Assert
      expect(tasks.length, 2);
      expect(tasks.first.title, 'Buy groceries');
      expect(tasks.first.isCompleted, false);
      expect(tasks.last.title, 'Read Flutter docs');
      expect(tasks.last.isCompleted, true);

      // ApiClient должен быть вызван ровно 1 раз
      verify(() => mockApiClient.getTasks(fakeToken)).called(1);
    });

    test('возвращает пустой список если API вернул []', () async {
      // Arrange
      when(() => mockApiClient.getTasks(fakeToken))
          .thenAnswer((_) async => []);

      // Act
      final tasks = await repository.getTasks();

      // Assert
      expect(tasks, isEmpty);
    });

    test('выбрасывает исключение если нет токена', () async {
      // Arrange — токен отсутствует
      when(() => mockLocalStorage.getToken()).thenAnswer((_) async => null);

      // Act + Assert
      expect(() => repository.getTasks(), throwsException);

      // ApiClient НЕ должен вызываться без токена
      verifyNever(() => mockApiClient.getTasks(any()));
    });

    test('пробрасывает ошибку от ApiClient', () async {
      // Arrange
      when(() => mockApiClient.getTasks(fakeToken))
          .thenThrow(Exception('Network error'));

      // Act + Assert
      expect(() => repository.getTasks(), throwsException);
    });
  });

  group('TaskRepository — addTask', () {
    const newTitle = 'New Task from Test';
    const newTaskDto = TaskDto(id: 'task_99', title: newTitle, isCompleted: false);

    test('создаёт задачу через API и возвращает доменный объект', () async {
      // Arrange
      when(() => mockApiClient.createTask(fakeToken, newTitle))
          .thenAnswer((_) async => newTaskDto);

      // Act
      final task = await repository.addTask(newTitle);

      // Assert
      expect(task.id, 'task_99');
      expect(task.title, newTitle);
      expect(task.isCompleted, false);

      verify(() => mockApiClient.createTask(fakeToken, newTitle)).called(1);
    });
  });

  group('TaskRepository — deleteTask', () {
    test('удаляет задачу через API', () async {
      // Arrange
      when(() => mockApiClient.deleteTask(fakeToken, 'task_1'))
          .thenAnswer((_) async {});

      // Act
      await repository.deleteTask('task_1');

      // Assert
      verify(() => mockApiClient.deleteTask(fakeToken, 'task_1')).called(1);
    });
  });
}
