import 'dart:ui';
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

  final List<Map<String, dynamic>> _categories = [
    {'id': 'idea', 'label': 'Ý tưởng', 'icon': Icons.lightbulb_outline_rounded},
    {'id': 'schedule', 'label': 'Lịch trình', 'icon': Icons.calendar_today_rounded},
    {'id': 'task', 'label': 'Công việc', 'icon': Icons.check_circle_outline_rounded},
    {'id': 'study', 'label': 'Học tập', 'icon': Icons.school_outlined},
  ];

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
                      'Thêm ghi chú mới',
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
                _buildFieldLabel('TIÊU ĐỀ GHI CHÚ', context),
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
                      hintText: 'Nhập tiêu đề...',
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

                // Field 2: Content
                _buildFieldLabel('NỘI DUNG', context),
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
                    controller: _contentController,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: context.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập chi tiết ý tưởng, tài liệu, ghi nhớ...',
                      hintStyle: TextStyle(
                        color: context.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 3: Category Chips
                _buildFieldLabel('PHÂN LOẠI & LIÊN KẾT', context),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = cat['id'] == _category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _category = cat['id']),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primary.withValues(alpha: 0.25)
                                      : const Color(0xFFEFF6FF))
                                  : (isDark
                                      ? const Color(0xFF2C2C2E).withValues(alpha: 0.6)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.primary : const Color(0xFF3B82F6))
                                    : (isDark
                                        ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                                        : const Color(0xFFE2E8F0)),
                                width: isSelected ? 1.3 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  size: 15,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                                      : context.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat['label'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                                        : context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (_category == 'schedule' || _category == 'task') ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2E).withValues(alpha: 0.65)
                          : const Color(0xFFEBEBF0).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3A3A3C).withValues(alpha: 0.5)
                            : const Color(0xFFDCDCE0).withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: TextField(
                      controller: _relationController,
                      style: TextStyle(fontSize: 13.5, color: context.textPrimary, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: _category == 'schedule' ? 'Tên lịch liên quan...' : 'Tên việc liên quan...',
                        hintStyle: TextStyle(color: context.textMuted, fontSize: 13, fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Submit Button (iOS Style Squircle with Primary Accent)
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
                                'Lưu ghi chú',
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

