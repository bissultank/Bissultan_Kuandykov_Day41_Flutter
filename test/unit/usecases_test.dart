// test/unit/usecases_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasks_app/domain/entities/task.dart';
import 'package:tasks_app/domain/entities/user.dart';
import 'package:tasks_app/domain/usecases/add_task_usecase.dart';
import 'package:tasks_app/domain/usecases/get_tasks_usecase.dart';
import 'package:tasks_app/domain/usecases/login_usecase.dart';
import '../mocks.dart';

void main() {
  group('LoginUseCase', () {
    late MockAuthRepository mockRepo;
    late LoginUseCase useCase;

    setUp(() {
      mockRepo = MockAuthRepository();
      useCase = LoginUseCase(mockRepo);
    });

    test('вызывает repository.login с правильными параметрами', () async {
      // Arrange
      const user = User(id: '1', email: 'a@b.com', token: 'tok');
      when(() => mockRepo.login(email: 'a@b.com', password: 'pass'))
          .thenAnswer((_) async => user);

      // Act
      final result = await useCase(email: 'a@b.com', password: 'pass');

      // Assert
      expect(result.email, 'a@b.com');
      verify(() => mockRepo.login(email: 'a@b.com', password: 'pass')).called(1);
    });

    test('выбрасывает ArgumentError при пустом email', () {
      expect(
        () => useCase(email: '', password: 'pass'),
        throwsArgumentError,
      );
      verifyNever(() => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('выбрасывает ArgumentError при пустом password', () {
      expect(
        () => useCase(email: 'test@test.com', password: ''),
        throwsArgumentError,
      );
    });
  });

  group('GetTasksUseCase', () {
    late MockTaskRepository mockRepo;
    late GetTasksUseCase useCase;

    setUp(() {
      mockRepo = MockTaskRepository();
      useCase = GetTasksUseCase(mockRepo);
    });

    test('возвращает задачи из repository', () async {
      // Arrange
      final tasks = [const Task(id: '1', title: 'Test', isCompleted: false)];
      when(() => mockRepo.getTasks()).thenAnswer((_) async => tasks);

      // Act
      final result = await useCase();

      // Assert
      expect(result, tasks);
      verify(() => mockRepo.getTasks()).called(1);
    });
  });

  group('AddTaskUseCase', () {
    late MockTaskRepository mockRepo;
    late AddTaskUseCase useCase;

    setUp(() {
      mockRepo = MockTaskRepository();
      useCase = AddTaskUseCase(mockRepo);
    });

    test('создаёт задачу через repository', () async {
      // Arrange
      const task = Task(id: '1', title: 'New', isCompleted: false);
      when(() => mockRepo.addTask('New')).thenAnswer((_) async => task);

      // Act
      final result = await useCase('New');

      // Assert
      expect(result.title, 'New');
      verify(() => mockRepo.addTask('New')).called(1);
    });

    test('trimming пробелов перед передачей в repository', () async {
      // Arrange
      const task = Task(id: '1', title: 'Trimmed', isCompleted: false);
      when(() => mockRepo.addTask('Trimmed')).thenAnswer((_) async => task);

      // Act — передаём с пробелами
      await useCase('  Trimmed  ');

      // Assert — repository вызван без пробелов
      verify(() => mockRepo.addTask('Trimmed')).called(1);
    });

    test('выбрасывает ArgumentError при пустом title', () {
      expect(() => useCase(''), throwsArgumentError);
      verifyNever(() => mockRepo.addTask(any()));
    });
  });
}
