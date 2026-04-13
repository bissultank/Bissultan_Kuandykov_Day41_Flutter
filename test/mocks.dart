// test/mocks.dart
//
// Барлық mock класстар осында жиналған.
// mocktail кітапханасы арқылы — код генерациясыз жұмыс істейді.

import 'package:mocktail/mocktail.dart';
import 'package:tasks_app/data/datasources/api_client.dart';
import 'package:tasks_app/data/datasources/local_storage.dart';
import 'package:tasks_app/domain/repositories/auth_repository.dart';
import 'package:tasks_app/domain/repositories/task_repository.dart';

// --- Mock: сыртқы зависимостілер (ApiClient, LocalStorage) ---

class MockApiClient extends Mock implements ApiClient {}

class MockLocalStorage extends Mock implements LocalStorage {}

// --- Mock: Repository деңгейі ---

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}
