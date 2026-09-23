import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/task_provider.dart';
import '../common/schedule_card.dart';
import '../schedules/add_schedule_sheet.dart';
import '../schedules/schedule_detail_dialog.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 15));
    final end = now.add(const Duration(days: 15));
    ref.read(scheduleProvider.notifier).fetchSchedulesForRange(start, end);
    ref.read(taskProvider.notifier).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final calState = ref.watch(calendarProvider);
    final scheduleState = ref.watch(scheduleProvider);
    final taskState = ref.watch(taskProvider);

    final selectedDate = calState.selectedDate;
    final selectedIso = DateFormatter.formatIsoDate(selectedDate);
    final weekDays = DateFormatter.getWeekDays(selectedDate);

    final todaySchedules = scheduleState.schedules.where((s) => s.startDate == selectedIso).toList();
    final todayTasks = taskState.tasks.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Greeting & Action Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Xin chào, ${authState.user?.name ?? 'bạn'} 👋',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatDisplayDateVi(selectedDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7-Day Horizontal Week Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDays.map((day) {
                      final isSelected = DateFormatter.isSameDay(day, selectedDate);
                      final isToday = DateFormatter.isToday(day);
                      final dayIso = DateFormatter.formatIsoDate(day);
                      final hasEvent = scheduleState.schedules.any((s) => s.startDate == dayIso);

                      return InkWell(
                        onTap: () => ref.read(calendarProvider.notifier).selectDate(day),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: (!isSelected && isToday)
                                ? Border.all(color: AppColors.primary, width: 1.2)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormatter.formatWeekdayHeader(day),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : (day.weekday == DateTime.sunday ? AppColors.error : AppColors.outline),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (day.weekday == DateTime.sunday ? AppColors.error : AppColors.onSurface),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasEvent
                                      ? (isSelected ? Colors.white : AppColors.primary)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Section 1: Today Schedule Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LỊCH TRÌNH TRONG NGÀY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${todaySchedules.length} sự kiện',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Schedule Cards List
                if (scheduleState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (todaySchedules.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_today_outlined, color: AppColors.outline, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có lịch trình cho ngày này',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => AddScheduleSheet.show(context, defaultDate: selectedDate),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm lịch trình'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...todaySchedules.map((schedule) {
                    return ScheduleCard(
                      schedule: schedule,
                      onTap: () => ScheduleDetailDialog.show(context, schedule),
                    );
                  }),

                const SizedBox(height: 24),

                // Section 2: Tasks Preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'VIỆC CẦN LÀM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                        letterSpacing: 0.8,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.go('/tasks'),
                      child: const Text(
                        'Xem tất cả →',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (todayTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text(
                        'Chưa có công việc nào cần làm',
                        style: TextStyle(fontSize: 13, color: AppColors.outline),
                      ),
                    ),
                  )
                else
                  ...todayTasks.map((task) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => ref.read(taskProvider.notifier).toggleTask(task.id),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task.completed ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: task.completed ? AppColors.primary : AppColors.outline,
                                  width: 1.8,
                                ),
                              ),
                              child: task.completed
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                                color: task.completed ? AppColors.outline : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
