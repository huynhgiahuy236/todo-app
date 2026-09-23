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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ghi chú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26),
            onPressed: () => AddNoteDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(noteProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(noteProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          const SizedBox(height: 8),

          // Notes List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(noteProvider.notifier).fetchNotes(),
              color: AppColors.primary,
              child: notes.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có ghi chú nào',
                        style: TextStyle(fontSize: 14, color: AppColors.outline),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
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
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: note.isPinned ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
          width: note.isPinned ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Relation Badge & Pin Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (note.scheduleTitle != null && note.scheduleTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Lịch: ${note.scheduleTitle}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                )
              else if (note.taskTitle != null && note.taskTitle!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.task_alt, size: 12, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Việc: ${note.taskTitle}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Ý tưởng',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.outline),
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 18,
                      color: note.isPinned ? AppColors.primary : AppColors.outline,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ref.read(noteProvider.notifier).togglePin(note.id),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ref.read(noteProvider.notifier).deleteNote(note.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.content,
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
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
                style: const TextStyle(fontSize: 11, color: AppColors.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
