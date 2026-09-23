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
    final daysWithEvents = weekDays.where((day) {
      final dayIso = DateFormatter.formatIsoDate(day);
      return allSchedules.any((s) => s.startDate == dayIso);
    }).toList();

    if (daysWithEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.containerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_available_rounded, color: context.textMuted, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                'Tuần này không có lịch trình',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bạn có thể thêm lịch học, công việc hoặc cuộc hẹn mới',
                style: TextStyle(fontSize: 13, color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      itemCount: daysWithEvents.length,
      itemBuilder: (context, index) {
        final day = daysWithEvents[index];
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
                            : (isToday ? AppColors.primary.withValues(alpha: 0.15) : context.containerLow),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormatter.formatDisplayDateVi(day),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.primary : context.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${daySchedules.length} sự kiện',
                      style: TextStyle(fontSize: 12, color: context.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Events for this day
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
