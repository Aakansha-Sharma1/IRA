import '../../domain/entities/todo_item.dart';
class TodoItemModel extends TodoItem {
  const TodoItemModel({required super.id, required super.title, super.description, super.dueDate, required super.isCompleted, required super.createdAt, required super.updatedAt});
  factory TodoItemModel.fromJson(Map<String, dynamic> json) => TodoItemModel(
    id: json['id'] as String, title: json['title'] as String, description: json['description'] as String?,
    dueDate: json['due_date'] == null ? null : DateTime.parse(json['due_date'] as String),
    isCompleted: json['is_completed'] as bool, createdAt: DateTime.parse(json['created_at'] as String), updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}
