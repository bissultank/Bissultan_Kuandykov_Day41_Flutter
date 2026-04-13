// lib/data/repositories/task_repository_impl.dart

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/api_client.dart';
import '../datasources/local_storage.dart';
import '../models/task_dto.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  TaskRepositoryImpl({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  Future<String> _getToken() async {
    final token = await _localStorage.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    return token;
  }

  @override
  Future<List<Task>> getTasks() async {
    final token = await _getToken();
    final dtos = await _apiClient.getTasks(token);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Task> addTask(String title) async {
    final token = await _getToken();
    final dto = await _apiClient.createTask(token, title);
    return dto.toDomain();
  }

  @override
  Future<void> deleteTask(String id) async {
    final token = await _getToken();
    await _apiClient.deleteTask(token, id);
  }

  @override
  Future<Task> toggleTask(String id) async {
    // В данном примере toggleTask — локальная операция без API
    throw UnimplementedError('toggleTask not implemented in this demo');
  }
}
