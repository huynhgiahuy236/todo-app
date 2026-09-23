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

  String _getUserInitial(String? name) {
    if (name == null || name.trim().isEmpty) return 'M';
    return name.trim().substring(0, 1).toUpperCase();
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
    final todayTasks = taskState.tasks.take(4).toList();

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
                // 1. Top Header Area (Greeting, Date & Profile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào buổi sáng 👋',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatDisplayDateVi(selectedDate),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Notification button
                        InkWell(
                          onTap: () => context.push('/settings'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_outlined, size: 22, color: AppColors.onSurface),
                                Positioned(
                                  top: 9,
                                  right: 9,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surfaceCard, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Avatar
                        InkWell(
                          onTap: () => context.push('/settings'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Center(
                              child: Text(
                                _getUserInitial(authState.user?.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Compact Weekly Calendar Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDays.map((day) {
                      final isSelected = DateFormatter.isSameDay(day, selectedDate);
                      final isToday = DateFormatter.isToday(day);
                      final dayIso = DateFormatter.formatIsoDate(day);
                      final hasEvent = scheduleState.schedules.any((s) => s.startDate == dayIso);

                      return Expanded(
                        child: InkWell(
                          onTap: () => ref.read(calendarProvider.notifier).selectDate(day),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: (!isSelected && isToday)
                                  ? Border.all(color: AppColors.primary.withOpacity(0.6), width: 1.2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormatter.formatWeekdayHeader(day),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.85)
                                        : (day.weekday == DateTime.sunday ? AppColors.error : AppColors.outline),
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 22),

                // 3. Section 1: Thời khóa biểu hôm nay
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'THỜI KHÓA BIỂU HÔM NAY',
                      style: TextStyle(
                        fontSize: 11,
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
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
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

                const SizedBox(height: 22),

                // 4. Section 2: Việc cần làm (Grouped Card List)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'VIỆC CẦN LÀM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                        letterSpacing: 0.8,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.go('/tasks'),
                      child: const Text(
                        'Xem tất cả',
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                    ),
                    child: const Center(
                      child: Text(
                        'Chưa có công việc nào cần làm',
                        style: TextStyle(fontSize: 13, color: AppColors.outline),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: todayTasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;
                          final isLast = index == todayTasks.length - 1;

                          return Column(
                            children: [
                              InkWell(
                                onTap: () => ref.read(taskProvider.notifier).toggleTask(task.id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: task.completed ? AppColors.primary : Colors.transparent,
                                          border: Border.all(
                                            color: task.completed ? AppColors.primary : AppColors.outlineVariant,
                                            width: 1.8,
                                          ),
                                        ),
                                        child: task.completed
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
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
                                ),
                              ),
                              if (!isLast) const Divider(height: 1, color: AppColors.divider),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 88),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
