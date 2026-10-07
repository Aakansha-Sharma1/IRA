import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, content, mood, createdAt, updatedAt];
}
