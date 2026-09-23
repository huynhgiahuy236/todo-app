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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text('Bạn có chắc muốn xóa lịch "${schedule.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Top Category Pill & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        AddScheduleSheet.show(context, initialSchedule: schedule);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _handleDelete(context, ref),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              schedule.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),

            // Time and Date Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withOpacity(0.6)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormatter.formatDisplayDateVi(DateFormatter.parseIsoDate(schedule.startDate)),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 10),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  if (schedule.isRecurring) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.repeat_rounded, size: 18, color: AppColors.tertiary),
                        const SizedBox(width: 10),
                        Text(
                          schedule.recurrence?.displayLabel ?? 'Lặp lại',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schedule.location!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Note if present
            if (schedule.note != null && schedule.note!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded, color: AppColors.outline, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schedule.note!,
                        style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
