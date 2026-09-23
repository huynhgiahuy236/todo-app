import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class TaskState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;

  TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TaskState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  int get totalCount => tasks.length;
  int get completedCount => tasks.where((t) => t.completed).length;
  double get completionProgress => totalCount == 0 ? 0.0 : completedCount / totalCount;
}

class TaskNotifier extends StateNotifier<TaskState> {
  TaskNotifier() : super(TaskState()) {
    fetchTasks();
  }

  Future<void> fetchTasks({String? date}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await ApiClient().dio.get(
        ApiEndpoints.tasks,
        queryParameters: date != null ? {'date': date} : null,
      );

      if (res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>)
            .map((item) => TaskModel.fromJson(item))
            .toList();

        state = state.copyWith(tasks: list, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: res.data['message'] ?? 'Lỗi khi tải công việc',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data?['message'] ?? 'Không thể tải công việc',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> createTask(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient().dio.post(ApiEndpoints.tasks, data: data);
      if (res.data['success'] == true) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleTask(String id) async {
    final originalTasks = state.tasks;
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t).toList(),
    );

    try {
      final res = await ApiClient().dio.patch(ApiEndpoints.taskToggle(id));
      if (res.data['success'] == true) {
        return true;
      } else {
        state = state.copyWith(tasks: originalTasks);
        return false;
      }
    } catch (_) {
      state = state.copyWith(tasks: originalTasks);
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      final res = await ApiClient().dio.delete(ApiEndpoints.taskDetail(id));
      if (res.data['success'] == true) {
        state = state.copyWith(
          tasks: state.tasks.where((t) => t.id != id).toList(),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier();
});
