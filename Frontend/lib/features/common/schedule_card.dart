import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';
import '../../core/constants/app_colors.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final bool isOngoing;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.isOngoing = false,
  });

  Color _parseCardColor() {
    try {
      if (schedule.color.startsWith('#')) {
        final hex = schedule.color.replaceFirst('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return AppColors.getCategoryColor(schedule.type);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _parseCardColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOngoing ? AppColors.primary.withOpacity(0.5) : AppColors.divider.withOpacity(0.6),
          width: isOngoing ? 1.5 : 0.8,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored Left Stripe
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Card Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time and Category Pill Row
                        Row(
                          children: [
                            if (isOngoing)
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              '${schedule.startTime} - ${schedule.endTime}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isOngoing ? AppColors.primary : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                schedule.type,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            if (schedule.isRecurring) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.repeat, size: 14, color: AppColors.outline.withOpacity(0.8)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Title
                        Text(
                          schedule.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Location or Note
                        if (schedule.location != null && schedule.location!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.outline),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  schedule.location!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ] else if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.notes_outlined, size: 14, color: AppColors.outline),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  schedule.note!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Chevron Icon
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Center(
                    child: Icon(Icons.chevron_right, color: AppColors.outlineVariant, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
