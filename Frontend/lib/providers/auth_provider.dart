import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await SecureStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final res = await ApiClient().dio.get(ApiEndpoints.getMe);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final user = UserModel.fromJson(res.data['data']);
        await SecureStorageService.saveUserData(id: user.id, name: user.name, email: user.email);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        await SecureStorageService.clearAuth();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      final localUser = await SecureStorageService.getUserData();
      if (localUser['id'] != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel(
            id: localUser['id']!,
            name: localUser['name'] ?? 'User',
            email: localUser['email'] ?? '',
          ),
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await ApiClient().dio.post(ApiEndpoints.login, data: {
        'email': email.trim(),
        'password': password,
      });

      if (res.data['success'] == true) {
        final token = res.data['data']['token'];
        final user = UserModel.fromJson(res.data['data']['user']);

        await SecureStorageService.saveAuthToken(token);
        await SecureStorageService.saveUserData(id: user.id, name: user.name, email: user.email);

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: res.data['message'] ?? 'Đăng nhập thất bại',
        );
        return false;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Không thể kết nối đến máy chủ';
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: msg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await ApiClient().dio.post(ApiEndpoints.register, data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (res.data['success'] == true) {
        final token = res.data['data']['token'];
        final user = UserModel.fromJson(res.data['data']['user']);

        await SecureStorageService.saveAuthToken(token);
        await SecureStorageService.saveUserData(id: user.id, name: user.name, email: user.email);

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: res.data['message'] ?? 'Đăng ký thất bại',
        );
        return false;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Không thể kết nối đến máy chủ';
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: msg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clearAuth();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
