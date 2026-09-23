import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/schedule_provider.dart';
import 'widgets/day_view_widget.dart';
import 'widgets/week_view_widget.dart';
import 'widgets/month_view_widget.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentRange();
    });
  }

  void _fetchCurrentRange() {
    final calState = ref.read(calendarProvider);
    final selected = calState.selectedDate;
    final start = selected.subtract(const Duration(days: 45));
    final end = selected.add(const Duration(days: 45));
    ref.read(scheduleProvider.notifier).fetchSchedulesForRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calendarProvider);
    final scheduleState = ref.watch(scheduleProvider);

    final selectedDate = calState.selectedDate;
    final selectedIso = DateFormatter.formatIsoDate(selectedDate);
    final weekDays = DateFormatter.getWeekDays(selectedDate);

    final daySchedules = scheduleState.schedules.where((s) => s.startDate == selectedIso).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch trình'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(calendarProvider.notifier).goToToday();
              _fetchCurrentRange();
            },
            icon: const Icon(Icons.today, size: 18, color: AppColors.primary),
            label: const Text(
              'Hôm nay',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Segmented Control [ Ngày ] [ Tuần ] [ Tháng ]
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                _buildSegmentButton(
                  title: 'Ngày',
                  mode: CalendarViewMode.day,
                  currentMode: calState.viewMode,
                ),
                _buildSegmentButton(
                  title: 'Tuần',
                  mode: CalendarViewMode.week,
                  currentMode: calState.viewMode,
                ),
                _buildSegmentButton(
                  title: 'Tháng',
                  mode: CalendarViewMode.month,
                  currentMode: calState.viewMode,
                ),
              ],
            ),
          ),

          // 2. Week Strip Navigation (shown in Day & Week views)
          if (calState.viewMode != CalendarViewMode.month)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  // Month Navigator Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatMonthYear(selectedDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              final prevWeek = selectedDate.subtract(const Duration(days: 7));
                              ref.read(calendarProvider.notifier).selectDate(prevWeek);
                              _fetchCurrentRange();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              final nextWeek = selectedDate.add(const Duration(days: 7));
                              ref.read(calendarProvider.notifier).selectDate(nextWeek);
                              _fetchCurrentRange();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 7-Day Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDays.map((day) {
                      final isSelected = DateFormatter.isSameDay(day, selectedDate);
                      final isToday = DateFormatter.isToday(day);
                      final dayIso = DateFormatter.formatIsoDate(day);
                      final hasEvent = scheduleState.schedules.any((s) => s.startDate == dayIso);

                      return InkWell(
                        onTap: () {
                          ref.read(calendarProvider.notifier).selectDate(day);
                          _fetchCurrentRange();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: (!isSelected && isToday)
                                ? Border.all(color: AppColors.primary, width: 1.2)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormatter.formatWeekdayHeader(day),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : (day.weekday == DateTime.sunday ? AppColors.error : AppColors.outline),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (day.weekday == DateTime.sunday ? AppColors.error : AppColors.onSurface),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasEvent
                                      ? (isSelected ? Colors.white : AppColors.primary)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // 3. Main View Switcher
          Expanded(
            child: calState.viewMode == CalendarViewMode.day
                ? DayViewWidget(selectedDate: selectedDate, schedules: daySchedules)
                : calState.viewMode == CalendarViewMode.week
                    ? WeekViewWidget(selectedDate: selectedDate, allSchedules: scheduleState.schedules)
                    : MonthViewWidget(
                        selectedDate: selectedDate,
                        focusedMonth: calState.focusedMonth,
                        allSchedules: scheduleState.schedules,
                        onDateSelected: (day) {
                          ref.read(calendarProvider.notifier).selectDate(day);
                          _fetchCurrentRange();
                        },
                        onMonthChanged: (month) {
                          ref.read(calendarProvider.notifier).changeFocusedMonth(month);
                          _fetchCurrentRange();
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required CalendarViewMode mode,
    required CalendarViewMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(calendarProvider.notifier).changeViewMode(mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 4)]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
