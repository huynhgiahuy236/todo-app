import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/schedule_model.dart';
import '../../models/task_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/task_provider.dart';
import '../schedules/schedule_detail_dialog.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final scheduleState = ref.watch(scheduleProvider);
    final taskState = ref.watch(taskProvider);

    final today = DateTime.now();
    final todayIso = DateFormatter.formatIsoDate(today);
    final tomorrowIso = DateFormatter.formatIsoDate(today.add(const Duration(days: 1)));

    // 1. Filter today & tomorrow schedules
    final upcomingSchedules = scheduleState.schedules.where((s) {
      return s.startDate == todayIso || s.startDate == tomorrowIso;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // 2. Filter pending tasks
    final pendingTasks = taskState.tasks.where((t) => !t.completed).toList();

    final totalAlerts = upcomingSchedules.length + pendingTasks.length;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.92)
                : const Color(0xFFF9F9FC).withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF38383A).withValues(alpha: 0.6)
                    : const Color(0xFFE5E5EA).withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: context.containerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông báo & Nhắc nhở',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              totalAlerts == 0
                                  ? 'Bạn đã cập nhật hết lịch trình'
                                  : '$totalAlerts mục cần lưu ý',
                              style: TextStyle(fontSize: 12, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/settings');
                        },
                        icon: Icon(Icons.tune_rounded, size: 20, color: context.textSecondary),
                        tooltip: 'Cài đặt thông báo',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),

                // Content list
                Expanded(
                  child: totalAlerts == 0
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: context.containerLow,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    size: 30,
                                    color: context.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Không có thông báo mới',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Mọi lịch trình và công việc đã được đồng bộ gọn gàng.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          children: [
                            // Section 1: Upcoming Schedules
                            if (upcomingSchedules.isNotEmpty) ...[
                              _buildSectionTitle(context, 'LỊCH TRÌNH SẮP ĐẾN (${upcomingSchedules.length})'),
                              const SizedBox(height: 8),
                              ...upcomingSchedules.map((schedule) {
                                final isToday = schedule.startDate == todayIso;
                                return _buildScheduleAlertItem(
                                  context: context,
                                  schedule: schedule,
                                  isToday: isToday,
                                  isDark: isDark,
                                  onTap: () {
                                    Navigator.pop(context);
                                    ScheduleDetailDialog.show(context, schedule);
                                  },
                                );
                              }),
                              const SizedBox(height: 16),
                            ],

                            // Section 2: Pending Tasks
                            if (pendingTasks.isNotEmpty) ...[
                              _buildSectionTitle(context, 'CÔNG VIỆC CHƯA HOÀN THÀNH (${pendingTasks.length})'),
                              const SizedBox(height: 8),
                              ...pendingTasks.map((task) {
                                return _buildTaskAlertItem(
                                  context: context,
                                  task: task,
                                  isDark: isDark,
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.go('/tasks');
                                  },
                                );
                              }),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: context.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildScheduleAlertItem({
    required BuildContext context,
    required ScheduleModel schedule,
    required bool isToday,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    Color cardAccentColor = AppColors.primary;
    try {
      if (schedule.color.startsWith('#')) {
        final hex = schedule.color.replaceFirst('#', '');
        cardAccentColor = Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderDivider),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cardAccentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_note_rounded, color: cardAccentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : context.containerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isToday ? 'Hôm nay' : 'Ngày mai',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isToday ? AppColors.primary : context.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${schedule.startTime} - ${schedule.endTime}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: context.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskAlertItem({
    required BuildContext context,
    required TaskModel task,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderDivider),
        boxShadow: AppColors.cardShadow(context),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.priority.isNotEmpty ? 'Ưu tiên: ${task.priority.toUpperCase()}' : 'Chưa hoàn thành',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: context.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
