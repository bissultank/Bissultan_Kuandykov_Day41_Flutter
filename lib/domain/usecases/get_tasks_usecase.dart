// lib/domain/usecases/get_tasks_usecase.dart

import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  Future<List<Task>> call() => _repository.getTasks();
}
