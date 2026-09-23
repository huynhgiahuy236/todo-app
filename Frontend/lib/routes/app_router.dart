import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/today/today_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/tasks/task_screen.dart';
import '../features/notes/note_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/common/quick_add_sheet.dart';
import '../features/schedules/add_schedule_sheet.dart';
import '../features/tasks/add_task_dialog.dart';
import '../features/notes/add_note_dialog.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/today',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }
      if (isAuth && isLoggingIn) {
        return '/today';
      }
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // 4-Tab Main Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Today
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          // Branch 2: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Branch 3: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TaskScreen(),
              ),
            ],
          ),
          // Branch 4: Notes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NoteScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNav({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _openQuickAdd(BuildContext context) {
    QuickAddSheet.show(
      context,
      onAddSchedule: () => AddScheduleSheet.show(context),
      onAddTask: () => AddTaskDialog.show(context),
      onAddNote: () => AddNoteDialog.show(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQuickAdd(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surfaceCard,
        elevation: 8,
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Hôm nay',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month,
              label: 'Lịch',
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              index: 2,
              icon: Icons.task_alt_outlined,
              activeIcon: Icons.task_alt,
              label: 'Việc',
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.note_alt_outlined,
              activeIcon: Icons.note_alt,
              label: 'Ghi chú',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    return InkWell(
      onTap: () => _onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.outline,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
