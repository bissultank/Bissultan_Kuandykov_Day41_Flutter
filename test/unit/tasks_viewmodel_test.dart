// test/unit/tasks_viewmodel_test.dart
//
// Тестируем TasksViewModel изолированно через MockTaskRepository.
// Firebase/HTTP не вызывается — тест быстрый и стабильный.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasks_app/domain/entities/task.dart';
import 'package:tasks_app/domain/usecases/add_task_usecase.dart';
import 'package:tasks_app/domain/usecases/get_tasks_usecase.dart';
import 'package:tasks_app/presentation/viewmodels/tasks_viewmodel.dart';
import '../mocks.dart';

void main() {
  late MockTaskRepository mockRepository;
  late GetTasksUseCase getTasksUseCase;
  late AddTaskUseCase addTaskUseCase;
  late TasksViewModel viewModel;

  final fakeTasks = [
    const Task(id: 'task_1', title: 'Buy groceries', isCompleted: false),
    const Task(id: 'task_2', title: 'Read Flutter docs', isCompleted: true),
  ];

  setUp(() {
    mockRepository = MockTaskRepository();
    getTasksUseCase = GetTasksUseCase(mockRepository);
    addTaskUseCase = AddTaskUseCase(mockRepository);
    viewModel = TasksViewModel(
      getTasksUseCase: getTasksUseCase,
      addTaskUseCase: addTaskUseCase,
      taskRepository: mockRepository,
    );
  });

  group('TasksViewModel — loadTasks', () {
    test('успешно загружает список задач', () async {
      // Arrange
      when(() => mockRepository.getTasks())
          .thenAnswer((_) async => fakeTasks);

      // Act
      await viewModel.loadTasks();

      // Assert
      expect(viewModel.tasks.length, 2);
      expect(viewModel.tasks.first.title, 'Buy groceries');
      expect(viewModel.tasks.last.title, 'Read Flutter docs');
      expect(viewModel.isLoading, false);
      expect(viewModel.hasError, false);

      // Метод getTasks вызван ровно 1 раз
      verify(() => mockRepository.getTasks()).called(1);
    });

    test('обрабатывает ошибку gracefully', () async {
      // Arrange — имитируем сетевую ошибку
      when(() => mockRepository.getTasks())
          .thenThrow(Exception('Network error'));

      // Act
      await viewModel.loadTasks();

      // Assert
      expect(viewModel.hasError, true);
      expect(viewModel.errorMessage, 'Network error');
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('загружает пустой список без ошибки', () async {
      // Arrange
      when(() => mockRepository.getTasks()).thenAnswer((_) async => []);

      // Act
      await viewModel.loadTasks();

      // Assert
      expect(viewModel.tasks, isEmpty);
      expect(viewModel.hasError, false);
    });
  });

  group('TasksViewModel — addTask', () {
    const newTask = Task(id: 'task_99', title: 'New Task', isCompleted: false);

    setUp(() {
      // Сначала загружаем задачи
      when(() => mockRepository.getTasks())
          .thenAnswer((_) async => List.from(fakeTasks));
    });

    test('добавляет задачу в список', () async {
      // Arrange
      when(() => mockRepository.getTasks())
          .thenAnswer((_) async => List.from(fakeTasks));
      when(() => mockRepository.addTask('New Task'))
          .thenAnswer((_) async => newTask);

      await viewModel.loadTasks();
      expect(viewModel.tasks.length, 2);

      // Act
      await viewModel.addTask('New Task');

      // Assert
      expect(viewModel.tasks.length, 3);
      expect(viewModel.tasks.last.title, 'New Task');
      verify(() => mockRepository.addTask('New Task')).called(1);
    });

    test('пустой заголовок не вызывает repository', () async {
      // Act
      await viewModel.addTask('');

      // Assert — repository НЕ должен вызываться
      verifyNever(() => mockRepository.addTask(any()));
    });

    test('строка из пробелов не вызывает repository', () async {
      // Act
      await viewModel.addTask('   ');

      // Assert
      verifyNever(() => mockRepository.addTask(any()));
    });
  });

  group('TasksViewModel — deleteTask', () {
    test('удаляет задачу из списка', () async {
      // Arrange
      when(() => mockRepository.getTasks())
          .thenAnswer((_) async => List.from(fakeTasks));
      when(() => mockRepository.deleteTask('task_1'))
          .thenAnswer((_) async {});

      await viewModel.loadTasks();
      expect(viewModel.tasks.length, 2);

      // Act
      await viewModel.deleteTask('task_1');

      // Assert
      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.id, 'task_2');
      verify(() => mockRepository.deleteTask('task_1')).called(1);
    });
  });
}
