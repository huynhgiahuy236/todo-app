import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/schedule_model.dart';
import '../../common/schedule_card.dart';
import '../../schedules/add_schedule_sheet.dart';
import '../../schedules/schedule_detail_dialog.dart';

class MonthViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final List<ScheduleModel> allSchedules;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  const MonthViewWidget({
    super.key,
    required this.selectedDate,
    required this.focusedMonth,
    required this.allSchedules,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  Color _parseColor(String colorStr, String type) {
    try {
      if (colorStr.startsWith('#')) {
        final hex = colorStr.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return AppColors.getCategoryColor(type);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIso = DateFormatter.formatIsoDate(selectedDate);
    final daySchedules = allSchedules.where((s) => s.startDate == selectedIso).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Calendar Table Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow(context),
            border: Border.all(color: context.borderDivider),
          ),
          child: TableCalendar<ScheduleModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            focusedDay: focusedMonth,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            rowHeight: 48,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
                letterSpacing: -0.2,
              ),
              leftChevronIcon: Icon(Icons.chevron_left_rounded, color: context.textSecondary, size: 22),
              rightChevronIcon: Icon(Icons.chevron_right_rounded, color: context.textSecondary, size: 22),
            ),
            selectedDayPredicate: (day) => DateFormatter.isSameDay(day, selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              onDateSelected(selectedDay);
              onMonthChanged(focusedDay);
            },
            onPageChanged: (focusedDay) {
              onMonthChanged(focusedDay);
            },
            eventLoader: (day) {
              final iso = DateFormatter.formatIsoDate(day);
              return allSchedules.where((s) => s.startDate == iso).toList();
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textMuted),
              weekendStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              markersAutoAligned: false,
              markersMaxCount: 0, // We control markers completely via custom builders
            ),
            calendarBuilders: CalendarBuilders(
              // 1. Selected Day
              selectedBuilder: (context, day, focusedDay) {
                final iso = DateFormatter.formatIsoDate(day);
                final dayEvents = allSchedules.where((s) => s.startDate == iso).toList();
                final hasEvents = dayEvents.isNotEmpty;
                final isDark = context.isDarkMode;
                final activeBg = isDark ? Colors.white : Colors.black;
                final textCol = isDark ? Colors.black : Colors.white;

                return Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: activeBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0x60000000) : const Color(0x28000000),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: textCol,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            height: 1.1,
                          ),
                        ),
                        if (hasEvents)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 3.5,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: textCol.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },

              // 2. Today (when not selected)
              todayBuilder: (context, day, focusedDay) {
                final isSelected = DateFormatter.isSameDay(day, selectedDate);
                if (isSelected) return null;
                final iso = DateFormatter.formatIsoDate(day);
                final hasEvents = allSchedules.any((s) => s.startDate == iso);

                return Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.isDarkMode
                          ? Colors.white.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.08),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            height: 1.1,
                          ),
                        ),
                        if (hasEvents)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 3.5,
                            height: 3.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },

              // 3. Default Days
              defaultBuilder: (context, day, focusedDay) {
                final iso = DateFormatter.formatIsoDate(day);
                final dayEvents = allSchedules.where((s) => s.startDate == iso).toList();
                final isWeekend = day.weekday == DateTime.sunday;

                return Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isWeekend ? AppColors.error : context.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            height: 1.1,
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 3.5,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: _parseColor(dayEvents.first.color, dayEvents.first.type),
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 5.5),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Selected Date Schedule Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatDisplayDateVi(selectedDate),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
              ),
              Text(
                '${daySchedules.length} sự kiện',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),

        // Selected Date Schedules List
        if (daySchedules.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Không có lịch trình cho ngày này',
                  style: TextStyle(fontSize: 13, color: AppColors.outline),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => AddScheduleSheet.show(context, defaultDate: selectedDate),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm lịch cho ngày này'),
                ),
              ],
            ),
          )
        else
          ...daySchedules.map((schedule) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ScheduleCard(
                schedule: schedule,
                onTap: () => ScheduleDetailDialog.show(context, schedule),
              ),
            );
          }),
      ],
    );
  }
}

