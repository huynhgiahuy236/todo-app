import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/schedule_model.dart';

class ScheduleCard extends StatefulWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final bool isOngoing;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.isOngoing = false,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool _isPressed = false;

  Color _getAccentColor() {
    final title = widget.schedule.title.toLowerCase();
    final type = widget.schedule.type.toLowerCase();
    final colorStr = widget.schedule.color;

    // 1. Explicit color in schedule if customized
    if (colorStr.startsWith('#') &&
        colorStr != '#1677E8' &&
        colorStr != '#000000' &&
        colorStr != '#FFFFFF') {
      try {
        final hex = colorStr.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    // 2. Keyword rules:
    // Thi / Kiểm tra / Test / Exam -> Đỏ (#EF4444)
    if (title.contains('thi') ||
        title.contains('kiểm tra') ||
        title.contains('test') ||
        title.contains('exam')) {
      return const Color(0xFFEF4444);
    }

    // Học / Java / Lý thuyết / Study -> Xanh biển (#3B82F6)
    if (title.contains('java') ||
        title.contains('học') ||
        title.contains('study') ||
        type == 'study' ||
        type == 'học tập') {
      return const Color(0xFF3B82F6);
    }

    // Backend / Thực tập / Work / Dev -> Xanh lá (#10B981)
    if (title.contains('backend') ||
        title.contains('thực tập') ||
        title.contains('work') ||
        type == 'work' ||
        type == 'công việc' ||
        type == 'project') {
      return const Color(0xFF10B981);
    }

    // Deadline / Hạn chót / Quan trọng -> Vàng cam (#F59E0B)
    if (title.contains('deadline') ||
        title.contains('hạn') ||
        title.contains('gấp') ||
        type == 'important' ||
        type == 'quan trọng') {
      return const Color(0xFFF59E0B);
    }

    if (type == 'meeting' || title.contains('họp')) {
      return const Color(0xFF8B5CF6);
    }

    return const Color(0xFF3B82F6);
  }

  String _getCategoryLabel(String type) {
    switch (type.toLowerCase()) {
      case 'study':
      case 'học tập':
        return 'Học tập';
      case 'work':
      case 'công việc':
      case 'project':
        return 'Công việc';
      case 'personal':
      case 'cá nhân':
        return 'Cá nhân';
      case 'meeting':
      case 'họp':
        return 'Cuộc họp';
      case 'important':
      case 'quan trọng':
      case 'deadline':
        return 'Quan trọng';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;
    final isDark = context.isDarkMode;
    final accentColor = _getAccentColor();

    // Weekday bubbles: Monday(1) to Sunday(7)
    final activeDays = schedule.recurrence?.daysOfWeek ?? [];
    final weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    final timeDisplay = schedule.endTime.isNotEmpty
        ? '${schedule.startTime} - ${schedule.endTime}'
        : schedule.startTime;

    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left Accent Indicator Strip
            Positioned(
              left: 0,
              top: 10,
              bottom: 10,
              width: 4.5,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.45),
                      blurRadius: 6,
                      offset: const Offset(1, 0),
                    ),
                  ],
                ),
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Category Tag & Status Pill / Chevron
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCategoryLabel(schedule.type),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          if (widget.isOngoing)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ĐANG DIỄN RA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.textMuted,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: Title (Large, Bold, Clean)
                      Text(
                        schedule.title,
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

                      // Row 3: Time Range
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: accentColor),
                          const SizedBox(width: 5),
                          Text(
                            timeDisplay,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 4: Bottom Bar (Location/Note & Weekday Pills)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Location or Note or Status
                          Expanded(
                            child: Row(
                              children: [
                                if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                                  Icon(Icons.location_on_outlined, size: 13, color: context.textMuted),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      schedule.location!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: context.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ] else if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                                  Icon(Icons.notes_rounded, size: 13, color: context.textMuted),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      schedule.note!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: context.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    schedule.isRecurring ? 'Lịch lặp lại' : 'Một lần',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: context.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Right: Weekday Circular Pills
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(7, (index) {
                              final weekdayNumber = index + 1; // 1 = Monday, 7 = Sunday
                              final isActive = schedule.isRecurring
                                  ? activeDays.contains(weekdayNumber)
                                  : (DateTime.tryParse(schedule.startDate)?.weekday == weekdayNumber);

                              return Container(
                                margin: const EdgeInsets.only(left: 3),
                                width: 19,
                                height: 19,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? accentColor
                                      : (isDark
                                          ? const Color(0xFF2C2C2E)
                                          : const Color(0xFFE5E5EA).withValues(alpha: 0.6)),
                                ),
                                child: Center(
                                  child: Text(
                                    weekdayLabels[index],
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : context.textMuted,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
