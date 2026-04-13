// lib/domain/usecases/add_task_usecase.dart

import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository _repository;

  AddTaskUseCase(this._repository);

  Future<Task> call(String title) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Task title must not be empty');
    }
    return _repository.addTask(title.trim());
  }
}
