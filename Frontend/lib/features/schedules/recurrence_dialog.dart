import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/schedule_model.dart';

enum RecurrenceEditScope { single, future, series }

class RecurrenceDialog extends StatefulWidget {
  final ScheduleModel schedule;
  final String targetDate;
  final String? newTimeRange; // e.g. "19:00 - 20:30"
  final bool isDelete;

  const RecurrenceDialog({
    super.key,
    required this.schedule,
    required this.targetDate,
    this.newTimeRange,
    this.isDelete = false,
  });

  static Future<RecurrenceEditScope?> show(
    BuildContext context, {
    required ScheduleModel schedule,
    required String targetDate,
    String? newTimeRange,
    bool isDelete = false,
  }) {
    return showModalBottomSheet<RecurrenceEditScope>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => RecurrenceDialog(
        schedule: schedule,
        targetDate: targetDate,
        newTimeRange: newTimeRange,
        isDelete: isDelete,
      ),
    );
  }

  @override
  State<RecurrenceDialog> createState() => _RecurrenceDialogState();
}

class _RecurrenceDialogState extends State<RecurrenceDialog> {
  RecurrenceEditScope _selectedScope = RecurrenceEditScope.single;

  @override
  Widget build(BuildContext context) {
    final title = widget.isDelete ? 'Xóa lịch lặp lại?' : 'Chỉnh sửa lịch lặp?';
    final sub = widget.isDelete
        ? 'Lịch này thuộc chuỗi lặp lại. Bạn muốn xóa như thế nào?'
        : 'Lịch này thuộc chuỗi lặp lại. Bạn muốn áp dụng thay đổi như thế nào?';

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
            // Header with Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isDelete ? Icons.delete_outline : Icons.event_repeat,
                    color: widget.isDelete ? AppColors.error : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Schedule Info Pill
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.schedule.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                      const Text(' • ', style: TextStyle(color: AppColors.outlineVariant)),
                      Text(
                        widget.targetDate,
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (widget.newTimeRange != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${widget.schedule.startTime} - ${widget.schedule.endTime}',
                          style: const TextStyle(
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          widget.newTimeRange!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Option 1: Only this event
            _buildOptionCard(
              scope: RecurrenceEditScope.single,
              icon: Icons.today,
              title: widget.isDelete ? 'Chỉ xóa lịch này' : 'Chỉ lịch này',
              subtitle: 'Chỉ áp dụng cho ngày ${widget.targetDate}',
              isRecommended: true,
            ),
            const SizedBox(height: 10),
            // Option 2: This and following
            _buildOptionCard(
              scope: RecurrenceEditScope.future,
              icon: Icons.fast_forward,
              title: widget.isDelete ? 'Lịch này và các lịch sau' : 'Lịch này và các lịch sau',
              subtitle: 'Áp dụng từ ngày ${widget.targetDate} trở đi',
            ),
            const SizedBox(height: 10),
            // Option 3: Entire series
            _buildOptionCard(
              scope: RecurrenceEditScope.series,
              icon: Icons.all_inclusive,
              title: widget.isDelete ? 'Toàn bộ chuỗi lịch' : 'Toàn bộ chuỗi lịch',
              subtitle: 'Áp dụng cho mọi ngày trong chuỗi',
            ),
            const SizedBox(height: 20),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Hủy', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedScope),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDelete ? AppColors.error : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      widget.isDelete ? 'Xác nhận xóa' : 'Áp dụng',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required RecurrenceEditScope scope,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedScope == scope;

    return InkWell(
      onTap: () => setState(() => _selectedScope = scope),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLow : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.8 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryFixed : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Khuyên dùng',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
