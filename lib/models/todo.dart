class Todo {
  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
  final String id, title, description;
  final DateTime createdAt;
}
