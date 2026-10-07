import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final String id, title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt, updatedAt;
  const TodoItem({required this.id, required this.title, this.description, this.dueDate, required this.isCompleted, required this.createdAt, required this.updatedAt});
  @override List<Object?> get props => [id, title, description, dueDate, isCompleted, createdAt, updatedAt];
}
