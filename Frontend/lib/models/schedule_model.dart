class RecurrenceRule {
  final String type; // 'none' | 'daily' | 'weekly' | 'custom'
  final List<int> daysOfWeek; // 1 = Mon ... 7 = Sun
  final String? until; // YYYY-MM-DD

  RecurrenceRule({
    this.type = 'none',
    this.daysOfWeek = const [],
    this.until,
  });

  factory RecurrenceRule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RecurrenceRule();
    return RecurrenceRule(
      type: json['type'] ?? 'none',
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      until: json['until'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'daysOfWeek': daysOfWeek,
      'until': until,
    };
  }

  String get displayLabel {
    switch (type) {
      case 'daily':
        return 'Lặp lại hàng ngày';
      case 'weekly':
        return 'Lặp lại hàng tuần';
      case 'custom':
        final dayNames = {1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7', 7: 'CN'};
        final labels = daysOfWeek.map((d) => dayNames[d] ?? '').join(', ');
        return 'Thứ $labels hàng tuần';
      default:
        return 'Không lặp lại';
    }
  }
}

class ScheduleModel {
  final String id;
  final String userId;
  final String title;
  final String type;
  final String startDate; // YYYY-MM-DD
  final String endDate;
  final String startTime; // HH:mm
  final String endTime;
  final String color;
  final String? note;
  final String? location;
  final String? seriesId;
  final bool isRecurring;
  final RecurrenceRule? recurrence;
  final String originalScheduleId;

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.note,
    this.location,
    this.seriesId,
    this.isRecurring = false,
    this.recurrence,
    required this.originalScheduleId,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'other',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? json['startDate'] ?? '',
      startTime: json['startTime'] ?? '08:00',
      endTime: json['endTime'] ?? '09:00',
      color: json['color'] ?? '#1677E8',
      note: json['note'],
      location: json['location'],
      seriesId: json['seriesId'],
      isRecurring: json['isRecurring'] ?? (json['recurrence'] != null && json['recurrence']['type'] != 'none'),
      recurrence: RecurrenceRule.fromJson(json['recurrence']),
      originalScheduleId: json['originalScheduleId'] ?? json['_id'] ?? json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
      'note': note,
      'location': location,
      'seriesId': seriesId,
      'recurrence': recurrence?.toJson(),
    };
  }
}
