// lib/presentation/viewmodels/tasks_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';

enum TasksState { initial, loading, loaded, error }

class TasksViewModel extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final TaskRepository _taskRepository;

  TasksState _state = TasksState.initial;
  List<Task> _tasks = [];
  String? _errorMessage;

  TasksViewModel({
    required GetTasksUseCase getTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required TaskRepository taskRepository,
  })  : _getTasksUseCase = getTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        _taskRepository = taskRepository;

  TasksState get state => _state;
  List<Task> get tasks => List.unmodifiable(_tasks);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TasksState.loading;
  bool get hasError => _state == TasksState.error;

  Future<void> loadTasks() async {
    _state = TasksState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _getTasksUseCase();
      _state = TasksState.loaded;
    } catch (e) {
      _state = TasksState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    try {
      final task = await _addTaskUseCase(title);
      _tasks = [..._tasks, task];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskRepository.deleteTask(id);
      _tasks = _tasks.where((t) => t.id != id).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
}
