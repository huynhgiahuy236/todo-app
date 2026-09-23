class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? dueDate; // YYYY-MM-DD
  final String? dueTime; // HH:mm
  final String priority; // 'low' | 'medium' | 'high'
  final bool completed;
  final String? note;
  final String? category;
  final DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.dueDate,
    this.dueTime,
    this.priority = 'medium',
    this.completed = false,
    this.note,
    this.category,
    this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      dueDate: json['dueDate'],
      dueTime: json['dueTime'],
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
      note: json['note'],
      category: json['category'] ?? 'General',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'priority': priority,
      'completed': completed,
      'note': note,
      'category': category,
    };
  }

  TaskModel copyWith({
    String? title,
    String? dueDate,
    String? dueTime,
    String? priority,
    bool? completed,
    String? note,
    String? category,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }
}
