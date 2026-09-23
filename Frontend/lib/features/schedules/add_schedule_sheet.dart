import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../core/services/notification_service.dart';
import 'recurrence_dialog.dart';

class AddScheduleSheet extends ConsumerStatefulWidget {
  final ScheduleModel? initialSchedule;
  final DateTime? defaultDate;

  const AddScheduleSheet({
    super.key,
    this.initialSchedule,
    this.defaultDate,
  });

  static Future<void> show(
    BuildContext context, {
    ScheduleModel? initialSchedule,
    DateTime? defaultDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddScheduleSheet(
        initialSchedule: initialSchedule,
        defaultDate: defaultDate,
      ),
    );
  }

  @override
  ConsumerState<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends ConsumerState<AddScheduleSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _endTime;

  String _selectedCategory = 'study';
  String _selectedColor = '#1677E8';
  String _recurrenceType = 'none'; // 'none' | 'daily' | 'weekly' | 'custom'
  List<int> _customWeekdays = [];
  String _reminderOption = 'Trước 15 phút';

  bool _isSubmitting = false;

  final Map<String, String> _categoryLabels = {
    'study': 'Học tập',
    'work': 'Công việc / Project',
    'personal': 'Cá nhân',
    'meeting': 'Cuộc họp',
    'important': 'Quan trọng / Deadline',
    'other': 'Khác',
  };

  @override
  void initState() {
    super.initState();
    final init = widget.initialSchedule;
    if (init != null) {
      _titleController.text = init.title;
      _noteController.text = init.note ?? '';
      _locationController.text = init.location ?? '';
      _selectedDate = DateFormatter.parseIsoDate(init.startDate);
      _startTime = _parseTimeOfDay(init.startTime);
      _endTime = init.endTime.isNotEmpty ? _parseTimeOfDay(init.endTime) : null;
      _selectedCategory = init.type;
      _selectedColor = init.color;
      _recurrenceType = init.recurrence?.type ?? 'none';
      _customWeekdays = List.from(init.recurrence?.daysOfWeek ?? []);
    } else {
      _selectedDate = widget.defaultDate ?? DateTime.now();
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = context.isDarkMode;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1C1C1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.onSurface,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final isDark = context.isDarkMode;
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1C1C1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.onSurface,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final isDark = context.isDarkMode;
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1C1C1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.onSurface,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _pickReminder() {
    final options = [
      'Đúng giờ',
      'Trước 5 phút',
      'Trước 10 phút',
      'Trước 15 phút',
      'Trước 30 phút',
      'Trước 1 tiếng',
      'Trước 2 tiếng',
      'Trước 1 ngày',
      'Trước 2 ngày',
      'Trước 3 ngày',
      'Trước 1 tuần',
      'Không nhắc',
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: ctx.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: ctx.borderDivider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Nhắc nhở thông báo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ctx.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((opt) {
                      final isSelected = opt == _reminderOption;
                      return InkWell(
                        onTap: () {
                          setState(() => _reminderOption = opt);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? ctx.textPrimary : ctx.textSecondary,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_rounded, color: ctx.textPrimary, size: 20),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleLocalReminder(String title, String startTimeStr) {
    if (_reminderOption == 'Không nhắc') return;

    Duration offset = Duration.zero;
    if (_reminderOption == 'Trước 5 phút') {
      offset = const Duration(minutes: 5);
    } else if (_reminderOption == 'Trước 10 phút') {
      offset = const Duration(minutes: 10);
    } else if (_reminderOption == 'Trước 15 phút') {
      offset = const Duration(minutes: 15);
    } else if (_reminderOption == 'Trước 30 phút') {
      offset = const Duration(minutes: 30);
    } else if (_reminderOption == 'Trước 1 tiếng' || _reminderOption == 'Trước 1 giờ') {
      offset = const Duration(hours: 1);
    } else if (_reminderOption == 'Trước 2 tiếng' || _reminderOption == 'Trước 2 giờ') {
      offset = const Duration(hours: 2);
    } else if (_reminderOption == 'Trước 1 ngày') {
      offset = const Duration(days: 1);
    } else if (_reminderOption == 'Trước 2 ngày') {
      offset = const Duration(days: 2);
    } else if (_reminderOption == 'Trước 3 ngày') {
      offset = const Duration(days: 3);
    } else if (_reminderOption == 'Trước 1 tuần') {
      offset = const Duration(days: 7);
    }

    final scheduleStart = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final reminderTime = scheduleStart.subtract(offset);

    if (reminderTime.isAfter(DateTime.now())) {
      final loc = _locationController.text.trim();
      NotificationService().scheduleNotification(
        id: title.hashCode,
        title: '⏰ Nhắc lịch: $title',
        body: 'Sắp diễn ra lúc $startTimeStr${loc.isNotEmpty ? ' tại $loc' : ''}',
        scheduledDate: reminderTime,
      );
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên sự kiện')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final isoDate = DateFormatter.formatIsoDate(_selectedDate);
    final startTimeStr = _formatTimeOfDay(_startTime);
    final endTimeStr = _endTime != null ? _formatTimeOfDay(_endTime!) : '';

    final payload = {
      'title': title,
      'type': _selectedCategory,
      'startDate': isoDate,
      'endDate': isoDate,
      'startTime': startTimeStr,
      'endTime': endTimeStr,
      'color': _selectedColor,
      'note': _noteController.text.trim(),
      'location': _locationController.text.trim(),
      'recurrence': {
        'type': _recurrenceType,
        'daysOfWeek': _recurrenceType == 'custom'
            ? _customWeekdays
            : _recurrenceType == 'weekly'
                ? [_selectedDate.weekday]
                : [],
        'until': null,
      },
    };

    final calState = ref.read(calendarProvider);
    final rangeStart = calState.selectedDate.subtract(const Duration(days: 35));
    final rangeEnd = calState.selectedDate.add(const Duration(days: 35));

    final init = widget.initialSchedule;

    if (init == null) {
      final success = await ref.read(scheduleProvider.notifier).createSchedule(
            payload,
            rangeStart,
            rangeEnd,
          );
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          _scheduleLocalReminder(title, startTimeStr);
          Navigator.pop(context);
        }
      }
    } else {
      if (init.isRecurring) {
        final scope = await RecurrenceDialog.show(
          context,
          schedule: init,
          targetDate: isoDate,
          newTimeRange: endTimeStr.isNotEmpty ? '$startTimeStr - $endTimeStr' : startTimeStr,
        );

        if (scope == null) {
          setState(() => _isSubmitting = false);
          return;
        }

        bool success = false;
        if (scope == RecurrenceEditScope.single) {
          success = await ref.read(scheduleProvider.notifier).updateOccurrence(
                init.originalScheduleId,
                isoDate,
                payload,
                rangeStart,
                rangeEnd,
              );
        } else if (scope == RecurrenceEditScope.future) {
          success = await ref.read(scheduleProvider.notifier).updateFuture(
                init.originalScheduleId,
                isoDate,
                payload,
                rangeStart,
                rangeEnd,
              );
        } else {
          success = await ref.read(scheduleProvider.notifier).updateSeries(
                init.originalScheduleId,
                payload,
                rangeStart,
                rangeEnd,
              );
        }

        if (mounted) {
          setState(() => _isSubmitting = false);
          if (success) {
            _scheduleLocalReminder(title, startTimeStr);
            Navigator.pop(context);
          }
        }
      } else {
        final success = await ref.read(scheduleProvider.notifier).updateSchedule(
              init.originalScheduleId,
              payload,
              rangeStart,
              rangeEnd,
            );
        if (mounted) {
          setState(() => _isSubmitting = false);
          if (success) {
            _scheduleLocalReminder(title, startTimeStr);
            Navigator.pop(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSchedule != null;
    final isDark = context.isDarkMode;

    final cardBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.70)
        : Colors.white.withValues(alpha: 0.85);
    final cardBorder = isDark
        ? const Color(0xFF3A3A3C).withValues(alpha: 0.6)
        : const Color(0xFFE5E5EA).withValues(alpha: 0.8);
    final pillBg = isDark
        ? const Color(0xFF3A3A3C).withValues(alpha: 0.8)
        : const Color(0xFFF2F2F7);
    final pillBorder = isDark
        ? const Color(0xFF48484A)
        : const Color(0xFFE5E5EA);

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
          padding: EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 38,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),

                  // Top Bar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.containerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: context.textSecondary, size: 18),
                        ),
                      ),
                      Text(
                        isEditing ? 'Chỉnh sửa lịch' : 'Thêm lịch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextButton(
                        onPressed: _isSubmitting ? null : _handleSave,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          elevation: 1,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Xong',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Group 1: EVENT TITLE CARD
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TÊN LỊCH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: context.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _titleController,
                          autofocus: !isEditing,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập tên sự kiện hoặc lịch học...',
                            hintStyle: TextStyle(
                              color: context.textMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Group 2: DATE & TIME SELECTION
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: Date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: context.containerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.calendar_month_rounded, color: context.textPrimary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ngày',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: pillBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: pillBorder, width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormatter.formatDisplayDateVi(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded, size: 16, color: context.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, indent: 64, endIndent: 16, color: cardBorder),

                        // Row 2: Time Interval
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: context.containerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.schedule_rounded, color: context.textPrimary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Thời gian',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: _pickStartTime,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: pillBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: pillBorder, width: 0.8),
                                      ),
                                      child: Text(
                                        _formatTimeOfDay(_startTime),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(Icons.arrow_forward_rounded, size: 14, color: context.textSecondary),
                                  ),
                                  if (_endTime == null)
                                    InkWell(
                                      onTap: _pickEndTime,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: pillBg,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: pillBorder, width: 0.8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add_rounded, size: 14, color: context.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Kết thúc',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: context.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      decoration: BoxDecoration(
                                        color: pillBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: pillBorder, width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: _pickEndTime,
                                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10, top: 7, bottom: 7, right: 4),
                                              child: Text(
                                                _formatTimeOfDay(_endTime!),
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: context.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => setState(() => _endTime = null),
                                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8, left: 2, top: 7, bottom: 7),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 14,
                                                color: context.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, indent: 64, endIndent: 16, color: cardBorder),

                        // Row 3: Reminder
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: context.containerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.notifications_active_outlined, color: context.textPrimary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Nhắc nhở',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _pickReminder,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: pillBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: pillBorder, width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _reminderOption,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded, size: 16, color: context.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Group 3: CATEGORY & COLOR SWATCHES
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: Category
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: context.containerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.category_outlined, color: context.textPrimary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loại lịch',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: pillBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: pillBorder, width: 0.8),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.expand_more_rounded, size: 18, color: context.textSecondary),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                  dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                  items: _categoryLabels.entries.map((e) {
                                    return DropdownMenuItem(
                                      value: e.key,
                                      child: Text(
                                        e.value,
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: context.textPrimary),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, indent: 64, endIndent: 16, color: cardBorder),

                        // Row 2: Color Swatches
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: context.containerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.palette_outlined, color: context.textPrimary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Màu sắc',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: AppColors.scheduleColorSwatches.map((color) {
                                        final hex = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                                        final isSelected = _selectedColor.toUpperCase() == hex.toUpperCase();
                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedColor = hex),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: isSelected
                                                  ? Border.all(color: Colors.white, width: 2.5)
                                                  : Border.all(color: Colors.black.withValues(alpha: 0.08), width: 0.8),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: color.withValues(alpha: 0.6),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check, size: 15, color: Colors.white)
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Group 4: REPETITION / LẶP LẠI
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: context.containerLow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.repeat_rounded, color: context.textPrimary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Lặp lại',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: pillBorder, width: 0.8),
                              ),
                              child: DropdownButton<String>(
                                value: _recurrenceType,
                                underline: const SizedBox(),
                                icon: Icon(Icons.unfold_more_rounded, size: 18, color: context.textSecondary),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimary,
                                ),
                                dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                items: const [
                                  DropdownMenuItem(value: 'none', child: Text('Không lặp')),
                                  DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                                  DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                                  DropdownMenuItem(value: 'custom', child: Text('Tùy chọn thứ')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _recurrenceType = val;
                                      if (val == 'custom' && _customWeekdays.isEmpty) {
                                        _customWeekdays = [_selectedDate.weekday];
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_recurrenceType == 'custom' || _recurrenceType == 'weekly') ...[
                          const SizedBox(height: 12),
                          Divider(height: 1, color: cardBorder),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ngày lặp',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildWeekdayChip(1, 'T2'),
                              _buildWeekdayChip(2, 'T3'),
                              _buildWeekdayChip(3, 'T4'),
                              _buildWeekdayChip(4, 'T5'),
                              _buildWeekdayChip(5, 'T6'),
                              _buildWeekdayChip(6, 'T7'),
                              _buildWeekdayChip(7, 'CN'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Group 5: LOCATION & NOTES
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorder, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        TextField(
                          controller: _locationController,
                          style: TextStyle(fontSize: 14, color: context.textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            icon: Icon(Icons.location_on_outlined, color: context.textSecondary, size: 20),
                            hintText: 'Địa điểm / Phòng học / Link online...',
                            hintStyle: TextStyle(color: context.textMuted, fontSize: 14, fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        Divider(height: 1, color: cardBorder),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          style: TextStyle(fontSize: 14, color: context.textPrimary, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            icon: Icon(Icons.notes_outlined, color: context.textSecondary, size: 20),
                            hintText: 'Ghi chú thêm...',
                            hintStyle: TextStyle(color: context.textMuted, fontSize: 14, fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayChip(int day, String label) {
    final isSelected = _recurrenceType == 'weekly'
        ? _selectedDate.weekday == day
        : _customWeekdays.contains(day);
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: () {
        if (_recurrenceType == 'weekly') return;
        setState(() {
          if (isSelected) {
            _customWeekdays.remove(day);
          } else {
            _customWeekdays.add(day);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF48484A) : const Color(0xFFE5E5EA)),
            width: 0.8,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : (day == 7 ? AppColors.error : context.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
