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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Row(
              children: const [
                Text(
                  'Thêm mới',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Options
            _buildOption(
              icon: Icons.calendar_month,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryFixed,
              title: 'Lịch trình',
              subtitle: 'Thêm buổi học, ca làm, cuộc họp hay sự kiện',
              onTap: () {
                Navigator.pop(context);
                onAddSchedule();
              },
            ),
            const Divider(height: 16, color: AppColors.divider),
            _buildOption(
              icon: Icons.task_alt,
              iconColor: AppColors.warning,
              iconBgColor: AppColors.warning.withOpacity(0.15),
              title: 'Việc cần làm',
              subtitle: 'Thêm đầu việc, bài tập và deadline',
              onTap: () {
                Navigator.pop(context);
                onAddTask();
              },
            ),
            const Divider(height: 16, color: AppColors.divider),
            _buildOption(
              icon: Icons.note_alt_outlined,
              iconColor: AppColors.catPersonal,
              iconBgColor: AppColors.catPersonal.withOpacity(0.15),
              title: 'Ghi chú',
              subtitle: 'Lưu ý tưởng, nội dung cần nhớ gắn với lịch/việc',
              onTap: () {
                Navigator.pop(context);
                onAddNote();
              },
            ),
            const SizedBox(height: 12),
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
            const Icon(Icons.chevron_right, color: AppColors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
