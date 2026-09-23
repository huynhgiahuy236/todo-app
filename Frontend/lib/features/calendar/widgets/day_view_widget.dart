import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/schedule_model.dart';
import '../../common/schedule_card.dart';
import '../../schedules/add_schedule_sheet.dart';
import '../../schedules/schedule_detail_dialog.dart';

class DayViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<ScheduleModel> schedules;

  const DayViewWidget({
    super.key,
    required this.selectedDate,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_busy, color: AppColors.outline, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không có lịch trình trong ngày này',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hãy thêm buổi học, công việc hoặc sự kiện mới',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => AddScheduleSheet.show(context, defaultDate: selectedDate),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm lịch trình'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 88),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return ScheduleCard(
          schedule: schedule,
          onTap: () => ScheduleDetailDialog.show(context, schedule),
        );
      },
    );
  }
}
