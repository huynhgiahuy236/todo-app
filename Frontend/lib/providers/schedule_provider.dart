import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/utils/date_formatter.dart';

class ScheduleState {
  final List<ScheduleModel> schedules;
  final bool isLoading;
  final String? errorMessage;
  final String? currentRangeKey;

  ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentRangeKey,
  });

  ScheduleState copyWith({
    List<ScheduleModel>? schedules,
    bool? isLoading,
    String? errorMessage,
    String? currentRangeKey,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentRangeKey: currentRangeKey ?? this.currentRangeKey,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(ScheduleState());

  Future<void> fetchSchedulesForRange(DateTime start, DateTime end, {bool force = false}) async {
    final startIso = DateFormatter.formatIsoDate(start);
    final endIso = DateFormatter.formatIsoDate(end);
    final rangeKey = '${startIso}_$endIso';

    if (!force && state.currentRangeKey == rangeKey && state.schedules.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await ApiClient().dio.get(
        ApiEndpoints.schedules,
        queryParameters: {'startDate': startIso, 'endDate': endIso},
      );

      if (res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>)
            .map((item) => ScheduleModel.fromJson(item))
            .toList();

        state = state.copyWith(
          schedules: list,
          isLoading: false,
          currentRangeKey: rangeKey,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: res.data['message'] ?? 'Lỗi khi tải lịch',
        );
      }
    } catch (e: any) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data?['message'] ?? 'Không thể tải lịch trình',
      );
    }
  }

  Future<bool> createSchedule(Map<String, dynamic> data, DateTime currentStart, DateTime currentEnd) async {
    try {
      final res = await ApiClient().dio.post(ApiEndpoints.schedules, data: data);
      if (res.data['success'] == true) {
        await fetchSchedulesForRange(currentStart, currentEnd, force: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSchedule(String id, Map<String, dynamic> data, DateTime currentStart, DateTime currentEnd) async {
    try {
      final res = await ApiClient().dio.patch(ApiEndpoints.scheduleDetail(id), data: data);
      if (res.data['success'] == true) {
        await fetchSchedulesForRange(currentStart, currentEnd, force: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 1. Chỉ lịch này (Only this event)
  Future<bool> updateOccurrence(
    String id,
    String targetDate,
    Map<String, dynamic> updateData,
    DateTime currentStart,
    DateTime currentEnd,
  ) async {
    try {
      final res = await ApiClient().dio.patch(
        ApiEndpoints.scheduleOccurrence(id),
        data: {'targetDate': targetDate, 'updateData': updateData},
      );
      if (res.data['success'] == true) {
        await fetchSchedulesForRange(currentStart, currentEnd, force: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 2. Lịch này và các lịch sau (This and future)
  Future<bool> updateFuture(
    String id,
    String targetDate,
    Map<String, dynamic> updateData,
    DateTime currentStart,
    DateTime currentEnd,
  ) async {
    try {
      final res = await ApiClient().dio.patch(
        ApiEndpoints.scheduleFuture(id),
        data: {'targetDate': targetDate, 'updateData': updateData},
      );
      if (res.data['success'] == true) {
        await fetchSchedulesForRange(currentStart, currentEnd, force: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 3. Toàn bộ chuỗi (Entire series)
  Future<bool> updateSeries(
    String id,
    Map<String, dynamic> updateData,
    DateTime currentStart,
    DateTime currentEnd,
  ) async {
    try {
      final res = await ApiClient().dio.patch(
        ApiEndpoints.scheduleSeries(id),
        data: updateData,
      );
      if (res.data['success'] == true) {
        await fetchSchedulesForRange(currentStart, currentEnd, force: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSchedule(
    String id,
    DateTime currentStart,
    DateTime currentEnd, {
    String? scope,
    String? targetDate,
  }) async {
    try {
      final res = await ApiClient().dio.delete(
        ApiEndpoints.scheduleDetail(id),
        queryParameters: {
          if (scope != null) 'scope': scope,
          if (targetDate != null) 'targetDate': targetDate,
        },
      );
      if (res.data['success'] == true) {
        await fetchSchedulesForRange(currentStart, currentEnd, force: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  return ScheduleNotifier();
});

// Helper provider: get schedules for a specific date
final schedulesForDateProvider = Provider.family<List<ScheduleModel>, String>((ref, isoDate) {
  final all = ref.watch(scheduleProvider).schedules;
  return all.where((s) => s.startDate == isoDate).toList();
});
