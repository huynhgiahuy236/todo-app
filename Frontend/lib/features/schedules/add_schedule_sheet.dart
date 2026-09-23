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
    final h = t.hour.toString().padStart(2, '0');
    final m = t.minute.toString().padStart(2, '0');
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
        // Auto bump end time if earlier than start time
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
      // Create new schedule
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
      // Edit existing schedule
      if (init.isRecurring) {
        // Show Recurrence Dialog for 3 options
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
        // Regular single schedule update
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
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.outline),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    isEditing ? 'Chỉnh sửa lịch' : 'Thêm lịch mới',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting ? null : _handleSave,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Lưu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Group 1: Title Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _titleController,
                  autofocus: !isEditing,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Tên sự kiện hoặc lịch học...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Group 2: Date & Time
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    // Date Row
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                      ),
                      title: const Text('Ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormatter.formatDisplayDateVi(_selectedDate),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16, color: AppColors.outline),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    // Time Interval Row
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.schedule, color: AppColors.secondary, size: 18),
                      ),
                      title: const Text('Thời gian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: _pickStartTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Text(
                                _formatTimeOfDay(_startTime),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('→', style: TextStyle(color: AppColors.outline)),
                          ),
                          InkWell(
                            onTap: _pickEndTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Text(
                                _formatTimeOfDay(_endTime),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
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

              // Group 3: Category & Color
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    // Category Dropdown
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.category_outlined, color: AppColors.tertiary, size: 18),
                      ),
                      title: const Text('Loại lịch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: DropdownButton<String>(
                        value: _selectedCategory,
                        underline: const SizedBox(),
                        items: _categoryLabels.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    // Color Swatches
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.palette_outlined, color: AppColors.onSurfaceVariant, size: 18),
                      ),
                      title: const Text('Màu sắc', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: AppColors.scheduleColorSwatches.map((color) {
                          final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                          final isSelected = _selectedColor.toUpperCase() == hex.toUpperCase();
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = hex),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Group 4: Recurrence
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.repeat, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Text('Lặp lại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _recurrenceType,
                          underline: const SizedBox(),
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
                      ],
                    ),
                    if (_recurrenceType == 'custom') ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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

              // Group 5: Location & Note
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.location_on_outlined, color: AppColors.outline, size: 20),
                        hintText: 'Địa điểm / Phòng học / Link online...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const Divider(height: 1),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.notes_outlined, color: AppColors.outline, size: 20),
                        hintText: 'Ghi chú thêm...',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayChip(int day, String label) {
    final isSelected = _customWeekdays.contains(day);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _customWeekdays.remove(day);
          } else {
            _customWeekdays.add(day);
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
