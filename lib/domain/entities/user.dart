// lib/domain/entities/user.dart

class User {
  final String id;
  final String email;
  final String token;

  const User({
    required this.id,
    required this.email,
    required this.token,
  });

  @override
  String toString() => 'User(id: $id, email: $email)';
}
