import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/calendar_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _startOfWeek = 'Thứ Hai';
  String _defaultView = 'Ngày';
  String _reminderTime = '15 phút';


  void _showPicker({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: context.borderDivider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              ...options.map((opt) {
                final isSelected = opt == current;
                return InkWell(
                  onTap: () {
                    onSelected(opt);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          opt,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? context.textPrimary : context.textSecondary,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_rounded, color: context.textPrimary, size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: null,
        toolbarHeight: 0,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large iOS-style Title
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20, left: 4),
                  child: Text(
                    'Cài đặt',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),

                // Group 1: GIAO DIỆN
                _buildSectionHeader('GIAO DIỆN', context),
                _buildGroupCard(
                  context,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildAppleIconBadge(
                            context.isDarkMode ? Icons.nightlight_round_rounded : Icons.wb_sunny_rounded,
                            context,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Chế độ tối',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: currentTheme == ThemeMode.dark || (currentTheme == ThemeMode.system && context.isDarkMode),
                            activeTrackColor: context.textPrimary,
                            onChanged: (val) {
                              ref.read(themeProvider.notifier).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Group 2: LỊCH TRÌNH
                _buildSectionHeader('LỊCH TRÌNH', context),
                _buildGroupCard(
                  context,
                  children: [
                    _buildSettingTile(
                      context: context,
                      icon: Icons.calendar_month_rounded,
                      title: 'Bắt đầu tuần từ',
                      value: _startOfWeek,
                      onTap: () {
                        _showPicker(
                          title: 'Chọn ngày bắt đầu tuần',
                          options: ['Thứ Hai', 'Chủ Nhật'],
                          current: _startOfWeek,
                          onSelected: (val) => setState(() => _startOfWeek = val),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 64, endIndent: 16, color: context.borderDivider),
                    _buildSettingTile(
                      context: context,
                      icon: Icons.view_week_rounded,
                      title: 'Chế độ xem lịch',
                      value: _defaultView,
                      onTap: () {
                        _showPicker(
                          title: 'Chế độ xem mặc định',
                          options: ['Ngày', 'Tuần', 'Tháng'],
                          current: _defaultView,
                          onSelected: (val) {
                            setState(() => _defaultView = val);
                            if (val == 'Ngày') {
                              ref.read(calendarProvider.notifier).changeViewMode(CalendarViewMode.day);
                            } else if (val == 'Tuần') {
                              ref.read(calendarProvider.notifier).changeViewMode(CalendarViewMode.week);
                            } else {
                              ref.read(calendarProvider.notifier).changeViewMode(CalendarViewMode.month);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Group 3: THÔNG BÁO
                _buildSectionHeader('THÔNG BÁO', context),
                _buildGroupCard(
                  context,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildAppleIconBadge(Icons.notifications_rounded, context),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Thông báo nhắc lịch',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _notificationsEnabled,
                            activeTrackColor: context.textPrimary,
                            onChanged: (val) {
                              setState(() => _notificationsEnabled = val);
                              if (val) {
                                NotificationService().requestPermissions();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, indent: 64, endIndent: 16, color: context.borderDivider),
                    _buildSettingTile(
                      context: context,
                      icon: Icons.timer_rounded,
                      title: 'Nhắc trước sự kiện',
                      value: _reminderTime,
                      onTap: () {
                        _showPicker(
                          title: 'Thời gian nhắc trước',
                          options: ['Đúng giờ', '5 phút', '15 phút', '30 phút', '1 giờ', '1 ngày'],
                          current: _reminderTime,
                          onSelected: (val) => setState(() => _reminderTime = val),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 64, endIndent: 16, color: context.borderDivider),
                    _buildSettingTile(
                      context: context,
                      icon: Icons.notifications_active_rounded,
                      title: 'Thử gửi thông báo ngay',
                      value: 'Bấm thử',
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final isDark = context.isDarkMode;
                        await NotificationService().showInstantNotification(
                          id: 9999,
                          title: '🔔 MySche - Thông báo thành công!',
                          body: 'Hệ thống thông báo trên điện thoại đã hoạt động cực tốt ✨',
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Đã kích hoạt thông báo thử nghiệm!'),
                              ],
                            ),
                            backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1E293B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Group 4: TÀI KHOẢN & ĐĂNG XUẤT
                _buildSectionHeader('TÀI KHOẢN', context),
                _buildGroupCard(
                  context,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: context.textPrimary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                authState.user?.name.isNotEmpty == true ? authState.user!.name.substring(0, 1).toUpperCase() : 'U',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: context.surfaceCard,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authState.user?.name ?? 'Tài khoản',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  authState.user?.email ?? 'Chưa đăng nhập',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, indent: 64, endIndent: 16, color: context.borderDivider),
                    InkWell(
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            _buildAppleIconBadge(Icons.logout_rounded, context, color: AppColors.error, iconColor: Colors.white),
                            const SizedBox(width: 14),
                            const Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 140), // Generous headroom for floating nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildAppleIconBadge(IconData icon, BuildContext context, {Color? color, Color? iconColor}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color ?? context.textPrimary,
        borderRadius: BorderRadius.circular(8.5),
      ),
      child: Icon(icon, color: iconColor ?? context.surfaceCard, size: 18),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildAppleIconBadge(icon, context),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: context.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

