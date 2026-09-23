import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CalendarViewMode { day, week, month }

class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final CalendarViewMode viewMode;

  CalendarState({
    required this.selectedDate,
    required this.focusedMonth,
    this.viewMode = CalendarViewMode.day,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedMonth,
    CalendarViewMode? viewMode,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier()
      : super(CalendarState(
          selectedDate: DateTime.now(),
          focusedMonth: DateTime(DateTime.now().year, DateTime.now().month, 1),
          viewMode: CalendarViewMode.day,
        ));

  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      focusedMonth: DateTime(date.year, date.month, 1),
    );
  }

  void changeViewMode(CalendarViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void changeFocusedMonth(DateTime month) {
    state = state.copyWith(focusedMonth: month);
  }

  void goToToday() {
    final now = DateTime.now();
    state = state.copyWith(
      selectedDate: now,
      focusedMonth: DateTime(now.year, now.month, 1),
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});
