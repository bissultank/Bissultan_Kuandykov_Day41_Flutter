// lib/core/di.dart
//
// Dependency Injection — подменяем зависимости тестовыми реализациями.
// В тестах передаём FakeApiClient вместо реального HTTP-клиента —
// это гарантирует отсутствие реальных сетевых запросов.

import '../data/datasources/api_client.dart';
import '../data/datasources/local_storage.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/usecases/add_task_usecase.dart';
import '../domain/usecases/get_tasks_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/viewmodels/tasks_viewmodel.dart';

class AppDependencies {
  final ApiClient apiClient;
  final LocalStorage localStorage;
  late final AuthRepository authRepository;
  late final TaskRepository taskRepository;
  late final LoginUseCase loginUseCase;
  late final GetTasksUseCase getTasksUseCase;
  late final AddTaskUseCase addTaskUseCase;
  late final AuthViewModel authViewModel;
  late final TasksViewModel tasksViewModel;

  AppDependencies({
    ApiClient? apiClient,
    LocalStorage? localStorage,
  })  : apiClient = apiClient ?? FakeApiClient(),
        localStorage = localStorage ?? InMemoryStorage() {
    _init();
  }

  void _init() {
    // Repositories
    authRepository = AuthRepositoryImpl(
      apiClient: apiClient,
      localStorage: localStorage,
    );
    taskRepository = TaskRepositoryImpl(
      apiClient: apiClient,
      localStorage: localStorage,
    );

    // Use Cases
    loginUseCase = LoginUseCase(authRepository);
    getTasksUseCase = GetTasksUseCase(taskRepository);
    addTaskUseCase = AddTaskUseCase(taskRepository);

    // ViewModels
    authViewModel = AuthViewModel(
      loginUseCase: loginUseCase,
      authRepository: authRepository,
    );
    tasksViewModel = TasksViewModel(
      getTasksUseCase: getTasksUseCase,
      addTaskUseCase: addTaskUseCase,
      taskRepository: taskRepository,
    );
  }
}
