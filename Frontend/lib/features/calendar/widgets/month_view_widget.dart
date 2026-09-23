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

    return Column(
      children: [
        // Calendar Table Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.divider.withOpacity(0.6)),
          ),
          child: TableCalendar<ScheduleModel>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            focusedDay: focusedMonth,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            rowHeight: 46,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.2,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.onSurfaceVariant, size: 22),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 22),
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
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.outline),
              weekendStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              todayTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              defaultTextStyle: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: const TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w500),
              outsideDaysVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                final isSelected = DateFormatter.isSameDay(day, selectedDate);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((event) {
                    final color = isSelected
                        ? Colors.white
                        : _parseColor(event.color, event.type);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              Text(
                '${daySchedules.length} sự kiện',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),

        // Selected Date Schedules List
        Expanded(
          child: daySchedules.isEmpty
              ? Center(
                  child: Padding(
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
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: daySchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = daySchedules[index];
                    return ScheduleCard(
                      schedule: schedule,
                      onTap: () => ScheduleDetailDialog.show(context, schedule),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
