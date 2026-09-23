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
        title: Row(
          children: [
            const Text(
              'Lịch',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.3),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MySche',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                ref.read(calendarProvider.notifier).goToToday();
                _fetchCurrentRange();
              },
              icon: const Icon(Icons.today_rounded, size: 16, color: AppColors.primary),
              label: const Text(
                'Hôm nay',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceCard,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Segmented Control [ Ngày ] [ Tuần ] [ Tháng ]
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider.withOpacity(0.6)),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.divider.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  // Month Navigator Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
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
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final prevWeek = selectedDate.subtract(const Duration(days: 7));
                              ref.read(calendarProvider.notifier).selectDate(prevWeek);
                              _fetchCurrentRange();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final nextWeek = selectedDate.add(const Duration(days: 7));
                              ref.read(calendarProvider.notifier).selectDate(nextWeek);
                              _fetchCurrentRange();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.onSurfaceVariant),
                            ),
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

                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            ref.read(calendarProvider.notifier).selectDate(day);
                            _fetchCurrentRange();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: (!isSelected && isToday)
                                  ? Border.all(color: AppColors.primary.withOpacity(0.6), width: 1.2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormatter.formatWeekdayHeader(day),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.85)
                                        : (day.weekday == DateTime.sunday ? AppColors.error : AppColors.outline),
                                  ),
                                ),
                                const SizedBox(height: 2),
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
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
