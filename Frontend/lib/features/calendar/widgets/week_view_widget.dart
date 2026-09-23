import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/schedule_model.dart';
import '../../common/schedule_card.dart';
import '../../schedules/schedule_detail_dialog.dart';

class WeekViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<ScheduleModel> allSchedules;

  const WeekViewWidget({
    super.key,
    required this.selectedDate,
    required this.allSchedules,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = DateFormatter.getWeekDays(selectedDate);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final day = weekDays[index];
        final dayIso = DateFormatter.formatIsoDate(day);
        final daySchedules = allSchedules.where((s) => s.startDate == dayIso).toList();
        final isSelected = DateFormatter.isSameDay(day, selectedDate);
        final isToday = DateFormatter.isToday(day);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Group Header
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isToday ? AppColors.primaryFixed : AppColors.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormatter.formatDisplayDateVi(day),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.primary : AppColors.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${daySchedules.length} sự kiện',
                      style: const TextStyle(fontSize: 12, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              // Events for this day
              if (daySchedules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  child: const Center(
                    child: Text(
                      'Trống lịch',
                      style: TextStyle(fontSize: 12, color: AppColors.outline),
                    ),
                  ),
                )
              else
                ...daySchedules.map((schedule) {
                  return ScheduleCard(
                    schedule: schedule,
                    onTap: () => ScheduleDetailDialog.show(context, schedule),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
