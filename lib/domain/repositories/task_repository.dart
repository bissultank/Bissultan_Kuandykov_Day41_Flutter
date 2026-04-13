// lib/domain/repositories/task_repository.dart

import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task> addTask(String title);
  Future<void> deleteTask(String id);
  Future<Task> toggleTask(String id);
}
