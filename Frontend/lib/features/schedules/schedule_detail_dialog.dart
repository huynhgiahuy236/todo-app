import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      useRootNavigator: true,
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

  String _getCategoryLabel(String type) {
    const map = {
      'study': 'Học tập',
      'work': 'Công việc / Project',
      'personal': 'Cá nhân',
      'meeting': 'Cuộc họp',
      'important': 'Quan trọng / Deadline',
      'other': 'Khác',
    };
    return map[type] ?? type.toUpperCase();
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'study':
        return Icons.school_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'meeting':
        return Icons.groups_rounded;
      case 'important':
        return Icons.priority_high_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final calState = ref.read(calendarProvider);
    final rangeStart = calState.selectedDate.subtract(const Duration(days: 35));
    final rangeEnd = calState.selectedDate.add(const Duration(days: 35));
    final isDark = context.isDarkMode;

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
          backgroundColor: isDark ? const Color(0xFF242426) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Xác nhận xóa',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: context.textPrimary,
            ),
          ),
          content: Text(
            'Bạn có chắc muốn xóa lịch "${schedule.title}"?',
            style: TextStyle(
              fontSize: 14.5,
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
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
    final isDark = context.isDarkMode;
    final accentColor = _parseColor();
    final categoryLabel = _getCategoryLabel(schedule.type);
    final categoryIcon = _getCategoryIcon(schedule.type);

    final cardBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.65)
        : const Color(0xFFF2F2F7).withValues(alpha: 0.85);
    final cardBorder = isDark
        ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
        : const Color(0xFFE5E5EA).withValues(alpha: 0.7);

    final timeDisplay = schedule.endTime.isNotEmpty
        ? '${schedule.startTime} - ${schedule.endTime}'
        : schedule.startTime;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.96),
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
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFD1D1D6),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Category Tag + Action Buttons (Edit / Delete)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 14, color: accentColor),
                            const SizedBox(width: 6),
                            Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons (Edit & Delete)
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context);
                              AddScheduleSheet.show(context, initialSchedule: schedule);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cardBorder, width: 0.8),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _handleDelete(context, ref),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF5A2E2E) : const Color(0xFFFFD4D4),
                                  width: 0.8,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Large Bold Schedule Title
                  Text(
                    schedule.title,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Grouped Information Card (Apple Style)
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder, width: 0.8),
                    ),
                    child: Column(
                      children: [
                        // Row 1: Date
                        _buildInfoRow(
                          context: context,
                          icon: Icons.calendar_month_rounded,
                          iconBgColor: isDark ? const Color(0xFF3A3A3C) : Colors.white,
                          iconColor: context.textPrimary,
                          label: 'Ngày',
                          value: DateFormatter.formatDisplayDateVi(DateFormatter.parseIsoDate(schedule.startDate)),
                        ),
                        Divider(height: 1, indent: 56, endIndent: 16, color: cardBorder),

                        // Row 2: Time
                        _buildInfoRow(
                          context: context,
                          icon: Icons.schedule_rounded,
                          iconBgColor: isDark ? const Color(0xFF3A3A3C) : Colors.white,
                          iconColor: context.textPrimary,
                          label: 'Thời gian',
                          value: timeDisplay,
                        ),

                        // Row 3: Recurrence (if any)
                        if (schedule.isRecurring) ...[
                          Divider(height: 1, indent: 56, endIndent: 16, color: cardBorder),
                          _buildInfoRow(
                            context: context,
                            icon: Icons.repeat_rounded,
                            iconBgColor: isDark ? const Color(0xFF3A3A3C) : Colors.white,
                            iconColor: context.textPrimary,
                            label: 'Lặp lại',
                            value: schedule.recurrence?.displayLabel ?? 'Lặp lại',
                          ),
                        ],

                        // Row 4: Location (if any)
                        if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                          Divider(height: 1, indent: 56, endIndent: 16, color: cardBorder),
                          _buildInfoRow(
                            context: context,
                            icon: Icons.location_on_outlined,
                            iconBgColor: isDark ? const Color(0xFF3A3A3C) : Colors.white,
                            iconColor: context.textPrimary,
                            label: 'Địa điểm',
                            value: schedule.location!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 5. Notes Section (if any)
                  if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.notes_rounded, size: 16, color: context.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                'GHI CHÚ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: context.textSecondary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            schedule.note!,
                            style: TextStyle(
                              fontSize: 14.5,
                              color: context.textPrimary,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
