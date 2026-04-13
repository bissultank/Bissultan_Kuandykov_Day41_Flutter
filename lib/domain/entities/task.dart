// lib/domain/entities/task.dart

class Task {
  final String id;
  final String title;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task(id: $id, title: $title, isCompleted: $isCompleted)';
}
