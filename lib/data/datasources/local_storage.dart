// lib/data/datasources/local_storage.dart

/// Abstract local storage — мокируется в unit-тестах
abstract class LocalStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

/// In-memory implementation — не зависит от SharedPreferences
class InMemoryStorage implements LocalStorage {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }
}
