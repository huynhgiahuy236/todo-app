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
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm ghi chú mới',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Field 1: Title
            const Text(
              'TIÊU ĐỀ GHI CHÚ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Nhập tiêu đề...',
                hintStyle: const TextStyle(color: AppColors.outline, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Field 2: Content
            const Text(
              'NỘI DUNG',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _contentController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Nhập chi tiết ý tưởng, tài liệu, ghi nhớ...',
                hintStyle: const TextStyle(color: AppColors.outline, fontWeight: FontWeight.normal),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Field 3: Category & Relation
            const Text(
              'PHÂN LOẠI & LIÊN KẾT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider.withOpacity(0.8)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
                      items: const [
                        DropdownMenuItem(
                          value: 'idea',
                          child: Text('Ý tưởng', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'schedule',
                          child: Text('Lịch trình', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'task',
                          child: Text('Công việc', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'study',
                          child: Text('Học tập', style: TextStyle(color: AppColors.catStudy, fontWeight: FontWeight.w600)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ),
                if (_category == 'schedule' || _category == 'task') ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _relationController,
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: _category == 'schedule' ? 'Tên lịch liên quan...' : 'Tên việc liên quan...',
                        hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13, fontWeight: FontWeight.normal),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu ghi chú', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
