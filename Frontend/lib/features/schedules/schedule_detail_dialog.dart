import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/calendar_provider.dart';
import 'add_schedule_sheet.dart';
import 'recurrence_dialog.dart';

class ScheduleDetailDialog extends ConsumerWidget {
  final ScheduleModel schedule;

  const ScheduleDetailDialog({super.key, required this.schedule});

  static void show(BuildContext context, ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScheduleDetailDialog(schedule: schedule),
    );
  }

  Color _parseColor() {
    try {
      if (schedule.color.startsWith('#')) {
        final hex = schedule.color.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return AppColors.getCategoryColor(schedule.type);
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final calState = ref.read(calendarProvider);
    final rangeStart = calState.selectedDate.subtract(const Duration(days: 35));
    final rangeEnd = calState.selectedDate.add(const Duration(days: 35));

    if (schedule.isRecurring) {
      final scope = await RecurrenceDialog.show(
        context,
        schedule: schedule,
        targetDate: schedule.startDate,
        isDelete: true,
      );

      if (scope == null) return;

      String? scopeStr;
      if (scope == RecurrenceEditScope.single) scopeStr = 'single';
      if (scope == RecurrenceEditScope.future) scopeStr = 'future';
      if (scope == RecurrenceEditScope.series) scopeStr = 'series';

      await ref.read(scheduleProvider.notifier).deleteSchedule(
            schedule.originalScheduleId,
            rangeStart,
            rangeEnd,
            scope: scopeStr,
            targetDate: schedule.startDate,
          );

      if (context.mounted) Navigator.pop(context);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa lịch "${schedule.title}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await ref.read(scheduleProvider.notifier).deleteSchedule(
              schedule.originalScheduleId,
              rangeStart,
              rangeEnd,
            );
        if (context.mounted) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = _parseColor();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Category Pill & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      onPressed: () {
                        Navigator.pop(context);
                        AddScheduleSheet.show(context, initialSchedule: schedule);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _handleDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              schedule.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Time and Date Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormatter.formatDisplayDateVi(DateFormatter.parseIsoDate(schedule.startDate)),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 10),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  if (schedule.isRecurring) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.repeat, size: 18, color: AppColors.tertiary),
                        const SizedBox(width: 10),
                        Text(
                          schedule.recurrence?.displayLabel ?? 'Lặp lại',
                          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Location if present
            if (schedule.location != null && schedule.location!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.location!,
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Note if present
            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined, color: AppColors.outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.note!,
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
