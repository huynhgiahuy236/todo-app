import 'package:flutter/material.dart';
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

  List<Color> _getCardGradient() {
    final type = widget.schedule.type.toLowerCase();
    if (widget.schedule.color.startsWith('#') && widget.schedule.color != '#1677E8' && widget.schedule.color != '#000000') {
      try {
        final hex = widget.schedule.color.replaceFirst('#', '');
        final base = Color(int.parse('FF$hex', radix: 16));
        return [base, HSLColor.fromColor(base).withLightness((HSLColor.fromColor(base).lightness * 0.8).clamp(0.0, 1.0)).toColor()];
      } catch (_) {}
    }

    switch (type) {
      case 'study':
      case 'học tập':
        return const [Color(0xFF3B4371), Color(0xFF262B48)]; // Night Indigo (Bed time / Study)
      case 'work':
      case 'công việc':
      case 'project':
        return const [Color(0xFF10B981), Color(0xFF047857)]; // Emerald Mint Green (Dinner / Work)
      case 'personal':
      case 'cá nhân':
        return const [Color(0xFFF59E0B), Color(0xFFD97706)]; // Warm Sun Amber (Homework / Personal)
      case 'meeting':
      case 'họp':
        return const [Color(0xFFF97316), Color(0xFFC2410C)]; // Sunset Coral (Coach / Meeting)
      case 'important':
      case 'deadline':
      case 'quan trọng':
        return const [Color(0xFFE11D48), Color(0xFF9F1239)]; // Rose Crimson (Important)
      default:
        return const [Color(0xFF6366F1), Color(0xFF4338CA)]; // Royal Indigo
    }
  }

  String _getCategoryLabel(String type) {
    switch (type.toLowerCase()) {
      case 'study':
        return 'Học tập';
      case 'work':
        return 'Công việc';
      case 'personal':
        return 'Cá nhân';
      case 'meeting':
        return 'Cuộc họp';
      case 'important':
        return 'Quan trọng';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getCardGradient();
    final schedule = widget.schedule;
    final primaryBg = gradientColors.first;

    // Weekday bubbles: Monday(1) to Sunday(7)
    final activeDays = schedule.recurrence?.daysOfWeek ?? [];
    final weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryBg.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: primaryBg.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Organic Wave Highlight Background Overlay
              Positioned(
                right: -20,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
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
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Category Tag & Status Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getCategoryLabel(schedule.type),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (widget.isOngoing)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ĐANG DIỄN RA',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: primaryBg,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 18,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Row 2 & 3: Time on Left, Large Bold Title on Right
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Time Range
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded, size: 16, color: Colors.white.withValues(alpha: 0.85)),
                                const SizedBox(width: 5),
                                Text(
                                  '${schedule.startTime} - ${schedule.endTime}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),

                            // Right: Big Bold Title
                            Expanded(
                              child: Text(
                                schedule.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Row 4: Bottom Bar (Location / Mode + Weekday Pills)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left subtitle (Location or Note or Mode)
                            Expanded(
                              child: Row(
                                children: [
                                  if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                                    Icon(Icons.location_on_outlined, size: 13, color: Colors.white.withValues(alpha: 0.8)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        schedule.location!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ] else if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                                    Icon(Icons.notes_outlined, size: 13, color: Colors.white.withValues(alpha: 0.8)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        schedule.note!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      schedule.isRecurring ? 'Lịch lặp lại' : 'Một lần',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Right: Weekday Circular Pills (S M T W T F S)
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
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.22),
                                  ),
                                  child: Center(
                                    child: Text(
                                      weekdayLabels[index],
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: isActive ? primaryBg : Colors.white.withValues(alpha: 0.9),
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
      ),
    );
  }
}
