class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String date; // YYYY-MM-DD
  final String? scheduleId;
  final String? scheduleTitle;
  final String? taskId;
  final String? taskTitle;
  final bool isPinned;
  final String category; // 'idea' | 'schedule' | 'task' | 'study'

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    this.content = '',
    required this.date,
    this.scheduleId,
    this.scheduleTitle,
    this.taskId,
    this.taskTitle,
    this.isPinned = false,
    this.category = 'idea',
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: json['date'] ?? '',
      scheduleId: json['scheduleId'],
      scheduleTitle: json['scheduleTitle'],
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
      isPinned: json['isPinned'] ?? false,
      category: json['category'] ?? 'idea',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'scheduleId': scheduleId,
      'scheduleTitle': scheduleTitle,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'isPinned': isPinned,
      'category': category,
    };
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? date,
    String? scheduleId,
    String? scheduleTitle,
    String? taskId,
    String? taskTitle,
    bool? isPinned,
    String? category,
  }) {
    return NoteModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduleTitle: scheduleTitle ?? this.scheduleTitle,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
    );
  }
}
