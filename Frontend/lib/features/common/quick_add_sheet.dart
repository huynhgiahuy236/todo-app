import 'dart:ui';
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
      useRootNavigator: true,
      isScrollControlled: true,
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
    final isDark = context.isDarkMode;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.88)
                : const Color(0xFFF9F9FC).withValues(alpha: 0.90),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tạo mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2E).withValues(alpha: 0.8)
                              : const Color(0xFFE5E5EA).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: context.textSecondary, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3 Minimal Action Cards
                Row(
                  children: [
                    _buildActionCard(
                      context: context,
                      icon: Icons.calendar_month_rounded,
                      label: 'Lịch trình',
                      onTap: () {
                        Navigator.pop(context);
                        onAddSchedule();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionCard(
                      context: context,
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Việc làm',
                      onTap: () {
                        Navigator.pop(context);
                        onAddTask();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionCard(
                      context: context,
                      icon: Icons.edit_note_rounded,
                      label: 'Ghi chú',
                      onTap: () {
                        Navigator.pop(context);
                        onAddNote();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2C2E).withValues(alpha: 0.65)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                  : const Color(0xFFE5E5EA).withValues(alpha: 0.8),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: context.surfaceCard, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
