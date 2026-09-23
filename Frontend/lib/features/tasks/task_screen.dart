import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'add_task_dialog.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final tasks = taskState.tasks;

    final pendingTasks = tasks.where((t) => !t.completed).toList();
    final completedTasks = tasks.where((t) => t.completed).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Việc cần làm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26),
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
              // 1. Top Progress Card (Tiến độ đầu ngày)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.task_alt, color: AppColors.primary, size: 18),
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
                        Text(
                          '${taskState.completedCount} / ${taskState.totalCount} hoàn thành',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
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
                          style: const TextStyle(fontSize: 12, color: AppColors.outline),
                        ),
                        Text(
                          pendingTasks.isEmpty
                              ? '🎉 Đã hoàn thành tất cả!'
                              : 'Còn ${pendingTasks.length} việc cần giải quyết',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: pendingTasks.isEmpty ? AppColors.success : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Pending Tasks Section
              const Text(
                'CẦN THỰC HIỆN',
                style: TextStyle(
                  fontSize: 12,
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
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Center(
                    child: Text(
                      tasks.isEmpty ? 'Chưa có công việc nào' : 'Tất cả công việc đã hoàn thành!',
                      style: const TextStyle(fontSize: 13, color: AppColors.outline),
                    ),
                  ),
                )
              else
                ...pendingTasks.map((task) => _buildTaskItem(context, ref, task)),

              // 3. Completed Tasks Section
              if (completedTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'ĐÃ HOÀN THÀNH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.outline,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${completedTasks.length})',
                      style: const TextStyle(fontSize: 12, color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...completedTasks.map((task) => _buildTaskItem(context, ref, task)),
              ],
              const SizedBox(height: 40),
            ],
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(taskProvider.notifier).deleteTask(task.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored Left Stripe for Priority
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: task.completed ? AppColors.outlineVariant : priorityColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      // Checkbox
                      InkWell(
                        onTap: () => ref.read(taskProvider.notifier).toggleTask(task.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.completed ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: task.completed ? AppColors.primary : AppColors.outline,
                              width: 1.8,
                            ),
                          ),
                          child: task.completed
                              ? const Icon(Icons.check, size: 15, color: Colors.white)
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                                color: task.completed ? AppColors.outline : AppColors.onSurface,
                              ),
                            ),
                            if (task.dueDate != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 13, color: AppColors.outline),
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
                          borderRadius: BorderRadius.circular(6),
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
