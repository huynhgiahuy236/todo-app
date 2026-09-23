import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/task_provider.dart';
import '../common/notifications_sheet.dart';
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
    final todayTasks = taskState.tasks.take(4).toList();
    final completedTasksCount = taskState.tasks.where((t) => t.completed).length;
    final totalTasksCount = taskState.tasks.length;
    final taskProgress = totalTasksCount > 0 ? (completedTasksCount / totalTasksCount) : 0.0;

    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Stack(
        children: [
          // 1. Marcelo Design X Ambient Glow Mesh Orbs (Background depth)
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8)).withValues(alpha: isDark ? 0.22 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF06B6D4) : const Color(0xFF38BDF8)).withValues(alpha: isDark ? 0.16 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFFEC4899) : const Color(0xFFF472B6)).withValues(alpha: isDark ? 0.14 : 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    _buildHeader(context, authState, selectedDate),
                    const SizedBox(height: 18),

                    // Weekly Calendar Strip (Frosted Glass)
                    _buildWeeklyCalendarStrip(context, weekDays, selectedDate, scheduleState),
                    const SizedBox(height: 18),

                    // Live Focus Hero Card (Only shown when there are active schedules today)
                    if (todaySchedules.isNotEmpty) ...[
                      _buildHeroFocusCard(
                        context: context,
                        todaySchedules: todaySchedules,
                        taskProgress: taskProgress,
                        completedTasksCount: completedTasksCount,
                        totalTasksCount: totalTasksCount,
                        selectedDate: selectedDate,
                      ),
                      const SizedBox(height: 22),
                    ],

                    // Section 1: Thời khóa biểu hôm nay
                    _buildSectionHeader(
                      title: 'THỜI KHÓA BIỂU HÔM NAY',
                      badge: '${todaySchedules.length} sự kiện',
                      onAction: () => AddScheduleSheet.show(context, defaultDate: selectedDate),
                      actionLabel: '+ Thêm',
                    ),
                    const SizedBox(height: 10),

                    // Schedule Cards
                    if (scheduleState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (todaySchedules.isEmpty)
                      _buildEmptyScheduleState(context, selectedDate)
                    else
                      ...todaySchedules.map((schedule) {
                        return ScheduleCard(
                          schedule: schedule,
                          onTap: () => ScheduleDetailDialog.show(context, schedule),
                        );
                      }),

                    const SizedBox(height: 22),

                    // Section 2: Việc cần làm (Tasks)
                    _buildSectionHeader(
                      title: 'VIỆC CẦN LÀM',
                      badge: '$completedTasksCount/$totalTasksCount xong',
                      onAction: () => context.go('/tasks'),
                      actionLabel: 'Xem tất cả',
                    ),
                    const SizedBox(height: 10),

                    _buildTasksSection(context, todayTasks),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic authState, DateTime selectedDate) {
    final isDark = context.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 2),
            Text(
              DateFormatter.formatDisplayDateVi(selectedDate),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        // Glass Notification Button
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                NotificationsSheet.show(context);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E).withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.notifications_outlined, size: 20, color: context.textPrimary),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendarStrip(
    BuildContext context,
    List<DateTime> weekDays,
    DateTime selectedDate,
    dynamic scheduleState,
  ) {
    final isDark = context.isDarkMode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final isSelected = DateFormatter.isSameDay(day, selectedDate);
              final isToday = DateFormatter.isToday(day);
              final dayIso = DateFormatter.formatIsoDate(day);
              final hasEvent = scheduleState.schedules.any((s) => s.startDate == dayIso);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(calendarProvider.notifier).selectDate(day);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.textPrimary
                            : (isToday ? context.textPrimary.withValues(alpha: 0.08) : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: context.textPrimary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
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
                                  ? context.surfaceCard
                                  : (day.weekday == DateTime.sunday ? AppColors.error : context.textMuted),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? context.surfaceCard
                                  : (day.weekday == DateTime.sunday ? AppColors.error : context.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 4.5,
                            height: 4.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasEvent
                                  ? (isSelected ? context.surfaceCard : const Color(0xFF10B981))
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFocusCard({
    required BuildContext context,
    required List<ScheduleModel> todaySchedules,
    required double taskProgress,
    required int completedTasksCount,
    required int totalTasksCount,
    required DateTime selectedDate,
  }) {
    final isDark = context.isDarkMode;
    final hasSchedule = todaySchedules.isNotEmpty;
    final nextSchedule = hasSchedule ? todaySchedules.first : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E293B).withValues(alpha: 0.85),
                      const Color(0xFF0F172A).withValues(alpha: 0.90),
                    ]
                  : [
                      const Color(0xFFFFFFFF).withValues(alpha: 0.90),
                      const Color(0xFFF1F5F9).withValues(alpha: 0.85),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0xFF000000).withValues(alpha: 0.45)
                    : const Color(0xFF64748B).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Status Capsule & Productivity Meter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasSchedule
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                          : const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasSchedule
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                            : const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasSchedule ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasSchedule ? 'TIÊU ĐIỂM TIẾP THEO' : 'NGÀY TỰ DO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: hasSchedule ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Task Ratio Indicator
                  Text(
                    '$completedTasksCount/$totalTasksCount việc hoàn thành',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Middle Content
              if (hasSchedule && nextSchedule != null) ...[
                Text(
                  nextSchedule.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: context.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${nextSchedule.startTime} - ${nextSchedule.endTime}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                    if (nextSchedule.location != null && nextSchedule.location!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined, size: 14, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          nextSchedule.location!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                Text(
                  'Không có lịch trình hôm nay',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn có trọn vẹn thời gian để tập trung vào các mục tiêu cá nhân.',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Bottom Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: taskProgress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String badge,
    required VoidCallback onAction,
    required String actionLabel,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: context.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: context.containerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onAction();
          },
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyScheduleState(BuildContext context, DateTime selectedDate) {
    final isDark = context.isDarkMode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.containerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_available_rounded, color: context.textMuted, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                'Lịch trình trống',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  AddScheduleSheet.show(context, defaultDate: selectedDate);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.textPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '+ Thêm sự kiện',
                    style: TextStyle(
                      color: context.surfaceCard,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, List<dynamic> todayTasks) {
    final isDark = context.isDarkMode;

    if (todayTasks.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            child: Center(
              child: Text(
                'Chưa có công việc nào cần làm',
                style: TextStyle(fontSize: 13, color: context.textMuted, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.85),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: todayTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              final isLast = index == todayTasks.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(taskProvider.notifier).toggleTask(task.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: task.completed ? const Color(0xFF10B981) : Colors.transparent,
                              border: Border.all(
                                color: task.completed ? const Color(0xFF10B981) : context.borderDivider,
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
                                fontWeight: FontWeight.w600,
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                                color: task.completed ? context.textMuted : context.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 52,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

