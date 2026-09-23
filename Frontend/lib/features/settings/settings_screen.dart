import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await SecureStorageService.getBaseUrl();
    _serverUrlController.text = url ?? ApiClient().dio.options.baseUrl;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveServerUrl() async {
    final url = _serverUrlController.text.trim();
    if (url.isNotEmpty) {
      await ApiClient().updateBaseUrl(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật địa chỉ máy chủ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group 1: GIAO DIỆN
            _buildSectionHeader('GIAO DIỆN'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.brightness_6, color: AppColors.primary, size: 18),
                    ),
                    title: const Text('Chế độ giao diện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                    child: Row(
                      children: [
                        _buildThemePill('Hệ thống', ThemeMode.system, currentTheme, Icons.settings_suggest),
                        const SizedBox(width: 8),
                        _buildThemePill('Sáng', ThemeMode.light, currentTheme, Icons.light_mode),
                        const SizedBox(width: 8),
                        _buildThemePill('Tối', ThemeMode.dark, currentTheme, Icons.dark_mode),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Group 2: LỊCH
            _buildSectionHeader('LỊCH TRÌNH'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month, color: AppColors.primary, size: 18),
                    ),
                    title: const Text('Bắt đầu tuần từ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Text('Thứ Hai', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.view_week, color: AppColors.primary, size: 18),
                    ),
                    title: const Text('Chế độ xem mặc định', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Text('Ngày', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Group 3: THÔNG BÁO
            _buildSectionHeader('THÔNG BÁO'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 18),
                    ),
                    title: const Text('Thông báo nhắc lịch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    value: _notificationsEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.schedule, color: AppColors.primary, size: 18),
                    ),
                    title: const Text('Nhắc trước sự kiện', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Text('15 phút', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Group 4: MÁY CHỦ API (Cấu hình linh hoạt)
            _buildSectionHeader('KẾT NỐI MÁY CHỦ (SERVER URL)'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Địa chỉ API Backend',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _serverUrlController,
                    decoration: InputDecoration(
                      hintText: 'http://localhost:5000/api',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save, color: AppColors.primary),
                        onPressed: _saveServerUrl,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Group 5: TÀI KHOẢN & ĐĂNG XUẤT
            _buildSectionHeader('TÀI KHOẢN'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryFixed,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(
                      authState.user?.name ?? 'Tài khoản',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      authState.user?.email ?? 'Chưa đăng nhập',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.outline,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildThemePill(String title, ThemeMode mode, ThemeMode current, IconData icon) {
    final isSelected = mode == current;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
