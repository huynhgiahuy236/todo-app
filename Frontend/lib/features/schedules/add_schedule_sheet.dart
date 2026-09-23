import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/calendar_provider.dart';
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
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  String _selectedCategory = 'study';
  String _selectedColor = '#1677E8';
  String _recurrenceType = 'none'; // 'none' | 'daily' | 'weekly' | 'custom'
  List<int> _customWeekdays = [];

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
      _endTime = _parseTimeOfDay(init.endTime);
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        final startMins = picked.hour * 60 + picked.minute;
        final endMins = _endTime.hour * 60 + _endTime.minute;
        if (endMins <= startMins) {
          _endTime = TimeOfDay(hour: (picked.hour + 1) % 24, minute: picked.minute);
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
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
    final endTimeStr = _formatTimeOfDay(_endTime);

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
          Navigator.pop(context);
        }
      }
    } else {
      if (init.isRecurring) {
        final scope = await RecurrenceDialog.show(
          context,
          schedule: init,
          targetDate: isoDate,
          newTimeRange: '$startTimeStr - $endTimeStr',
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
          if (success) Navigator.pop(context);
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
          if (success) Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSchedule != null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7FB), // Soft modern canvas
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Top Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF475569), size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isEditing ? 'Chỉnh sửa lịch' : 'Thêm lịch',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting ? null : _handleSave,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Xong',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Group 1: EVENT TITLE CARD
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TÊN LỊCH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _titleController,
                      autofocus: !isEditing,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên sự kiện hoặc lịch học...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
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
              const SizedBox(height: 16),

              // Group 2: DATE & TIME SELECTION
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  children: [
                    // Row 1: Date
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7E3FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Ngày',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormatter.formatDisplayDateVi(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFE2E8F0)),
                    // Row 2: Time Interval
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.schedule, color: Color(0xFF0D56B3), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Thời gian',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: _pickStartTime,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    _formatTimeOfDay(_startTime),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('→', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                              ),
                              InkWell(
                                onTap: _pickEndTime,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    _formatTimeOfDay(_endTime),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Group 3: CATEGORY & COLOR SWATCHES
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  children: [
                    // Row 1: Category
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC4E7FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.category_outlined, color: Color(0xFF006387), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Loại lịch',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              underline: const SizedBox(),
                              icon: const Icon(Icons.expand_more, size: 18, color: AppColors.primary),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                              dropdownColor: Colors.white,
                              items: _categoryLabels.entries.map((e) {
                                return DropdownMenuItem(
                                  value: e.key,
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
                    const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFE2E8F0)),
                    // Row 2: Color Swatches
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.palette_outlined, color: Color(0xFF475569), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Màu sắc',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Row(
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
                                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.5),
                                              blurRadius: 6,
                                              spreadRadius: 1.5,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Group 4: REPETITION / LẶP LẠI
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
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
                                color: const Color(0xFFD8E2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.repeat, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Lặp lại',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButton<String>(
                            value: _recurrenceType,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.unfold_more, size: 18, color: Color(0xFF64748B)),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            dropdownColor: Colors.white,
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
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Ngày lặp',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
              const SizedBox(height: 16),

              // Group 5: LOCATION & NOTES
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _locationController,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 20),
                        hintText: 'Địa điểm / Phòng học / Link online...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.notes_outlined, color: Color(0xFF64748B), size: 20),
                        hintText: 'Ghi chú thêm...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildWeekdayChip(int day, String label) {
    final isSelected = _recurrenceType == 'weekly'
        ? _selectedDate.weekday == day
        : _customWeekdays.contains(day);

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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
