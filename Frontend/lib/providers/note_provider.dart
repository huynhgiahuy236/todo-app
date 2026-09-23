import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class NoteState {
  final List<NoteModel> notes;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory; // 'all' | 'schedule' | 'task' | 'idea'
  final String searchQuery;

  NoteState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'all',
    this.searchQuery = '',
  });

  NoteState copyWith({
    List<NoteModel>? notes,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return NoteState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NoteNotifier extends StateNotifier<NoteState> {
  NoteNotifier() : super(NoteState()) {
    fetchNotes();
  }

  Future<void> fetchNotes({String? category, String? search}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cat = category ?? state.selectedCategory;
      final query = search ?? state.searchQuery;

      final res = await ApiClient().dio.get(
        ApiEndpoints.notes,
        queryParameters: {
          if (cat != 'all') 'category': cat,
          if (query.isNotEmpty) 'search': query,
        },
      );

      if (res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>)
            .map((item) => NoteModel.fromJson(item))
            .toList();

        state = state.copyWith(
          notes: list,
          isLoading: false,
          selectedCategory: cat,
          searchQuery: query,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: res.data['message'] ?? 'Lỗi khi tải ghi chú',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.response?.data?['message'] ?? 'Không thể tải ghi chú',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    fetchNotes(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchNotes(search: query);
  }

  Future<bool> createNote(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient().dio.post(ApiEndpoints.notes, data: data);
      if (res.data['success'] == true) {
        await fetchNotes();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> togglePin(String id) async {
    try {
      final res = await ApiClient().dio.patch(ApiEndpoints.notePin(id));
      if (res.data['success'] == true) {
        await fetchNotes();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      final res = await ApiClient().dio.delete(ApiEndpoints.noteDetail(id));
      if (res.data['success'] == true) {
        state = state.copyWith(
          notes: state.notes.where((n) => n.id != id).toList(),
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, NoteState>((ref) {
  return NoteNotifier();
});
