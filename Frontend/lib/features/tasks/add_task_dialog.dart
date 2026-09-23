import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
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
  final _noteController = TextEditingController();
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
    _noteController.dispose();
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
          ? '${_dueTime!.hour.toString().padStart(2, '0')}:${_dueTime!.minute.toString().padStart(2, '0')}'
          : null,
      'priority': _priority,
      'note': _noteController.text.trim(),
    };

    final success = await ref.read(taskProvider.notifier).createTask(payload);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm việc cần làm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.outline),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Tên công việc hoặc deadline...',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Date picker chip
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _dueDate != null ? DateFormatter.formatDayMonth(_dueDate!) : 'Hạn chót',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Priority selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButton<String>(
                    value: _priority,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Ưu tiên: Thấp')),
                      DropdownMenuItem(value: 'medium', child: Text('Ưu tiên: Vừa')),
                      DropdownMenuItem(value: 'high', child: Text('Ưu tiên: Cao')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSave,
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Thêm việc'),
            ),
          ],
        ),
      ),
    );
  }
}
