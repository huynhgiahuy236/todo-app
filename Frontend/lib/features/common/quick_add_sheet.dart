import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class QuickAddSheet extends StatelessWidget {
  final VoidCallback onAddSchedule;
  final VoidCallback onAddTask;
  final VoidCallback onAddNote;

  const QuickAddSheet({
    super.key,
    required this.onAddSchedule,
    required this.onAddTask,
    required this.onAddNote,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onAddSchedule,
    required VoidCallback onAddTask,
    required VoidCallback onAddNote,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickAddSheet(
        onAddSchedule: onAddSchedule,
        onAddTask: onAddTask,
        onAddNote: onAddNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạo mới nhanh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Options
            _buildOption(
              icon: Icons.calendar_month_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryFixed,
              title: 'Lịch trình / Buổi học',
              subtitle: 'Thêm buổi học, ca làm việc, cuộc họp hay sự kiện',
              onTap: () {
                Navigator.pop(context);
                onAddSchedule();
              },
            ),
            const SizedBox(height: 8),
            _buildOption(
              icon: Icons.task_alt_rounded,
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withOpacity(0.15),
              title: 'Việc cần làm / Deadline',
              subtitle: 'Thêm đầu việc, bài tập và hạn hoàn thành',
              onTap: () {
                Navigator.pop(context);
                onAddTask();
              },
            ),
            const SizedBox(height: 8),
            _buildOption(
              icon: Icons.edit_note_rounded,
              iconColor: AppColors.catPersonal,
              iconBgColor: AppColors.catPersonal.withOpacity(0.15),
              title: 'Ghi chú / Ý tưởng',
              subtitle: 'Lưu tài liệu, nội dung cần nhớ hoặc liên kết',
              onTap: () {
                Navigator.pop(context);
                onAddNote();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
