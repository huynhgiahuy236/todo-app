import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/services/notification_service.dart';
import '../../providers/task_provider.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final DateTime? defaultDate;

  const AddTaskDialog({super.key, this.defaultDate});

  static Future<void> show(BuildContext context, {DateTime? defaultDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskDialog(defaultDate: defaultDate),
    );
  }

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String _priority = 'medium'; // 'low' | 'medium' | 'high'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.defaultDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'title': title,
      'dueDate': _dueDate != null ? DateFormatter.formatIsoDate(_dueDate!) : null,
      'dueTime': _dueTime != null
          ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'priority': _priority,
    };

    final success = await ref.read(taskProvider.notifier).createTask(payload);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        if (_dueDate != null) {
          final targetTime = _dueTime ?? const TimeOfDay(hour: 9, minute: 0);
          final taskDateTime = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            targetTime.hour,
            targetTime.minute,
          );
          if (taskDateTime.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: title.hashCode,
              title: '🎯 Nhắc việc cần làm: $title',
              body: 'Hạn chót: ${_dueTime != null ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}' : '09:00'}',
              scheduledDate: taskDateTime,
            );
          }
        }
        Navigator.pop(context);
      }
    }
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
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
                : const Color(0xFFF9F9FC).withValues(alpha: 0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF38383A).withValues(alpha: 0.6)
                    : const Color(0xFFE5E5EA).withValues(alpha: 0.8),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // iOS Drag Handle
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

                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thêm việc cần làm',
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

                // Field 1: Title
                _buildFieldLabel('TÊN CÔNG VIỆC', context),
                const SizedBox(height: 7),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2E).withValues(alpha: 0.65)
                        : const Color(0xFFEBEBF0).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                          : const Color(0xFFDCDCE0).withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên việc cần làm, bài tập...',
                      hintStyle: TextStyle(
                        color: context.textMuted,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 2: Due Date & Priority
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date picker
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('HẠN CHÓT', context),
                          const SizedBox(height: 7),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) setState(() => _dueDate = picked);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2C2E).withValues(alpha: 0.65)
                                    : const Color(0xFFEBEBF0).withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                                      : const Color(0xFFDCDCE0).withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 18, color: context.textPrimary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dueDate != null ? DateFormatter.formatDayMonth(_dueDate!) : 'Chọn ngày',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Priority Selector
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('MỨC ĐỘ ƯU TIÊN', context),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2C2E).withValues(alpha: 0.65)
                                  : const Color(0xFFEBEBF0).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                                    : const Color(0xFFDCDCE0).withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildPriorityChip('low', 'Thấp', context),
                                _buildPriorityChip('medium', 'Vừa', context),
                                _buildPriorityChip('high', 'Cao', context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                // Submit Button (iOS Squircle with Primary Accent)
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isSubmitting ? null : _handleSave,
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Thêm công việc',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String id, String label, BuildContext context) {
    final isSelected = _priority == id;
    final isDark = context.isDarkMode;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF3A3A3C) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? context.textPrimary
                    : context.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
