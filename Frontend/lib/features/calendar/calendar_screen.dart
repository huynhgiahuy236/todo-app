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
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Lịch',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                ref.read(calendarProvider.notifier).goToToday();
                _fetchCurrentRange();
              },
              icon: Icon(Icons.today_rounded, size: 16, color: context.textPrimary),
              label: Text(
                'Hôm nay',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: context.textPrimary),
              ),
              style: TextButton.styleFrom(
                backgroundColor: context.surfaceCard,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: StadiumBorder(
                  side: BorderSide(color: context.borderDivider),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.containerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: context.borderDivider),
            ),
            child: Row(
              children: [
                _buildSegmentButton(
                  title: 'Ngày',
                  mode: CalendarViewMode.day,
                  currentMode: calState.viewMode,
                  context: context,
                ),
                _buildSegmentButton(
                  title: 'Tuần',
                  mode: CalendarViewMode.week,
                  currentMode: calState.viewMode,
                  context: context,
                ),
                _buildSegmentButton(
                  title: 'Tháng',
                  mode: CalendarViewMode.month,
                  currentMode: calState.viewMode,
                  context: context,
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
                color: context.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow(context),
                border: Border.all(color: context.borderDivider),
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
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
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.chevron_left_rounded, size: 22, color: context.textSecondary),
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
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(Icons.chevron_right_rounded, size: 22, color: context.textSecondary),
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
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: InkWell(
                            onTap: () {
                              ref.read(calendarProvider.notifier).selectDate(day);
                              _fetchCurrentRange();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (hasEvent ? const Color(0xFF10B981) : AppColors.primary)
                                    : (isToday ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (hasEvent ? const Color(0xFF10B981) : AppColors.primary).withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
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
                                          ? Colors.white
                                          : (day.weekday == DateTime.sunday ? AppColors.error : context.textMuted),
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
                                          : (isToday ? AppColors.primary : (day.weekday == DateTime.sunday ? AppColors.error : context.textPrimary)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: hasEvent
                                          ? (isSelected ? Colors.white : (isToday ? AppColors.primary : const Color(0xFF10B981)))
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
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
    required BuildContext context,
    required String title,
    required CalendarViewMode mode,
    required CalendarViewMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(calendarProvider.notifier).changeViewMode(mode),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
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
                color: isSelected ? context.textPrimary : context.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
