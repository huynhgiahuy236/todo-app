import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import 'add_note_dialog.dart';

class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key});

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteState = ref.watch(noteProvider);
    final notes = noteState.notes;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.containerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${notes.length} ghi chú',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            onPressed: () => AddNoteDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(noteProvider.notifier).setSearchQuery(val),
              style: TextStyle(fontSize: 14, color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu đề, nội dung...',
                hintStyle: TextStyle(color: context.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: context.textMuted, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(noteProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: context.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.borderDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.borderDivider),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tất cả', noteState.selectedCategory),
                const SizedBox(width: 8),
                _buildFilterChip('schedule', 'Gắn với Lịch', noteState.selectedCategory),
                const SizedBox(width: 8),
                _buildFilterChip('task', 'Gắn với Việc', noteState.selectedCategory),
                const SizedBox(width: 8),
                _buildFilterChip('idea', 'Ý tưởng', noteState.selectedCategory),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Notes List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(noteProvider.notifier).fetchNotes(),
              color: AppColors.primary,
              child: notes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: context.containerLow,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit_note_rounded, color: context.textMuted, size: 28),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Không có ghi chú nào',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bấm + để thêm ghi chú hoặc ý tưởng mới',
                              style: TextStyle(fontSize: 12, color: context.textMuted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 88),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _buildNoteCard(note);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, String currentCategory) {
    final isSelected = key == currentCategory;
    return InkWell(
      onTap: () => ref.read(noteProvider.notifier).setCategory(key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : context.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : context.borderDivider),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow(context),
        border: Border.all(
          color: note.isPinned ? AppColors.primary.withValues(alpha: 0.5) : context.borderDivider,
          width: note.isPinned ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Relation Badge & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (note.scheduleTitle != null && note.scheduleTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Lịch: ${note.scheduleTitle}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                )
              else if (note.taskTitle != null && note.taskTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.task_alt_rounded, size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Việc: ${note.taskTitle}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.containerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ý tưởng',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textMuted),
                  ),
                ),
              Row(
                children: [
                  InkWell(
                    onTap: () => ref.read(noteProvider.notifier).togglePin(note.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        size: 18,
                        color: note.isPinned ? AppColors.primary : context.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => ref.read(noteProvider.notifier).deleteNote(note.id),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            note.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.content,
              style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.date,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
