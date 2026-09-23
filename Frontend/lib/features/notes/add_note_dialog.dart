import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/note_provider.dart';

class AddNoteDialog extends ConsumerStatefulWidget {
  const AddNoteDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddNoteDialog(),
    );
  }

  @override
  ConsumerState<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _relationController = TextEditingController();
  String _category = 'idea'; // 'idea' | 'schedule' | 'task' | 'study'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'title': title,
      'content': _contentController.text.trim(),
      'date': DateFormatter.formatIsoDate(DateTime.now()),
      'category': _category,
      'scheduleTitle': _category == 'schedule' ? _relationController.text.trim() : null,
      'taskTitle': _category == 'task' ? _relationController.text.trim() : null,
    };

    final success = await ref.read(noteProvider.notifier).createNote(payload);
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
                  'Thêm ghi chú',
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
                hintText: 'Tiêu đề ghi chú...',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Nội dung ghi chú...',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButton<String>(
                    value: _category,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'idea', child: Text('Loại: Ý tưởng')),
                      DropdownMenuItem(value: 'schedule', child: Text('Gắn với Lịch')),
                      DropdownMenuItem(value: 'task', child: Text('Gắn với Việc')),
                      DropdownMenuItem(value: 'study', child: Text('Tài liệu học')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ),
                if (_category == 'schedule' || _category == 'task') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _relationController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _category == 'schedule' ? 'Tên lịch...' : 'Tên việc...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSave,
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu ghi chú'),
            ),
          ],
        ),
      ),
    );
  }
}
