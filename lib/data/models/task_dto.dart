// lib/data/models/task_dto.dart

import '../../domain/entities/task.dart';

class TaskDto {
  final String id;
  final String title;
  final bool isCompleted;

  const TaskDto({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'is_completed': isCompleted,
      };
}

// Extension: DTO → Domain
extension TaskDtoMapper on TaskDto {
  Task toDomain() => Task(
        id: id,
        title: title,
        isCompleted: isCompleted,
      );
}

// Extension: Domain → DTO
extension TaskMapper on Task {
  TaskDto toDto() => TaskDto(
        id: id,
        title: title,
        isCompleted: isCompleted,
      );
}
