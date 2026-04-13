// lib/data/models/user_dto.dart

import '../../domain/entities/user.dart';

class UserDto {
  final String id;
  final String email;
  final String token;

  const UserDto({
    required this.id,
    required this.email,
    required this.token,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'token': token,
      };
}

extension UserDtoMapper on UserDto {
  User toDomain() => User(id: id, email: email, token: token);
}
