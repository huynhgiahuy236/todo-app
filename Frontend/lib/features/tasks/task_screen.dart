import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'add_task_dialog.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  String _filter = 'all'; // 'all' | 'pending' | 'high' | 'completed'

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'cao':
        return AppColors.error;
      case 'medium':
      case 'vừa':
        return AppColors.warning;
      default:
        return AppColors.outline;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'cao':
        return 'Cao';
      case 'medium':
      case 'vừa':
        return 'Vừa';
      default:
        return 'Thấp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final allTasks = taskState.tasks;

    List<TaskModel> filteredTasks;
    if (_filter == 'pending') {
      filteredTasks = allTasks.where((t) => !t.completed).toList();
    } else if (_filter == 'completed') {
      filteredTasks = allTasks.where((t) => t.completed).toList();
    } else if (_filter == 'high') {
      filteredTasks = allTasks.where((t) => t.priority.toLowerCase() == 'high' || t.priority.toLowerCase() == 'cao').toList();
    } else {
      filteredTasks = allTasks;
    }

    final pendingTasks = filteredTasks.where((t) => !t.completed).toList();
    final completedTasks = filteredTasks.where((t) => t.completed).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MYSCHE TASKS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 0.8,
              ),
            ),
            const Text(
              'Việc cần làm',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
            onPressed: () => AddTaskDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskProvider.notifier).fetchTasks(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Progress Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${taskState.totalCount} công việc',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${taskState.completedCount}/${taskState.totalCount} hoàn thành',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: taskState.completionProgress,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceContainerLow,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiến độ: ${(taskState.completionProgress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.outline),
                        ),
                        Text(
                          taskState.totalCount > 0 && taskState.completedCount == taskState.totalCount
                              ? '🎉 Đã hoàn thành tất cả!'
                              : 'Còn ${taskState.totalCount - taskState.completedCount} việc cần làm',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: taskState.totalCount > 0 && taskState.completedCount == taskState.totalCount
                                ? AppColors.success
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill('all', 'Tất cả (${allTasks.length})'),
                    const SizedBox(width: 8),
                    _buildFilterPill('pending', 'Chưa xong (${taskState.totalCount - taskState.completedCount})'),
                    const SizedBox(width: 8),
                    _buildFilterPill('high', 'Ưu tiên cao'),
                    const SizedBox(width: 8),
                    _buildFilterPill('completed', 'Đã xong (${taskState.completedCount})'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Pending Tasks Section
              if (_filter != 'completed') ...[
                const Text(
                  'CẦN THỰC HIỆN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.outline,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                if (pendingTasks.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: AppColors.divider.withOpacity(0.6)),
                    ),
                    child: Center(
                      child: Text(
                        allTasks.isEmpty ? 'Chưa có công việc nào' : 'Không có công việc chưa hoàn thành!',
                        style: const TextStyle(fontSize: 13, color: AppColors.outline),
                      ),
                    ),
                  )
                else
                  ...pendingTasks.map((task) => _buildTaskItem(context, ref, task)),
              ],

              // 4. Completed Tasks Section
              if (completedTasks.isNotEmpty && _filter != 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'ĐÃ HOÀN THÀNH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${completedTasks.length})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...completedTasks.map((task) => _buildTaskItem(context, ref, task)),
              ],
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String key, String label) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider.withOpacity(0.8),
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 4)] : null,
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

  Widget _buildTaskItem(BuildContext context, WidgetRef ref, TaskModel task) {
    final priorityColor = _getPriorityColor(task.priority);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        ref.read(taskProvider.notifier).deleteTask(task.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored Left Stripe for Priority
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: task.completed ? AppColors.outlineVariant.withOpacity(0.5) : priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Checkbox
                      InkWell(
                        onTap: () => ref.read(taskProvider.notifier).toggleTask(task.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.completed ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: task.completed ? AppColors.primary : AppColors.outlineVariant,
                              width: 1.8,
                            ),
                          ),
                          child: task.completed
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and DueDate
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                                color: task.completed ? AppColors.outline : AppColors.onSurface,
                              ),
                            ),
                            if (task.dueDate != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 13, color: AppColors.outline),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.dueDate!,
                                    style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getPriorityLabel(task.priority),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
