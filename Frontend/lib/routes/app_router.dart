import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../providers/task_provider.dart';

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

      // 5-Tab Main Shell Route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Today
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          // Branch 1: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Branch 2: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TaskScreen(),
              ),
            ],
          ),
          // Branch 3: Notes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                builder: (context, state) => const NoteScreen(),
              ),
            ],
          ),
          // Branch 4: Settings / Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithBottomNav extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskState = ref.watch(taskProvider);
    final hasPendingTasks = taskState.tasks.any((t) => !t.completed);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 84,
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 10),
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Arched Glass Capsule Background (Curves smoothly up in the center)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CurvedNavBarPainter(isDark: isDark),
                    child: ClipPath(
                      clipper: CurvedNavBarClipper(),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

                // 2. Nav Items Row aligned with the base pill bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 54,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Home
                        _buildNavItem(
                          icon: Icons.home_rounded,
                          isActive: currentIndex == 0,
                          isDark: isDark,
                          onTap: () => _onTap(0),
                        ),

                        // 2. Calendar
                        _buildNavItem(
                          icon: Icons.calendar_month_rounded,
                          isActive: currentIndex == 1,
                          isDark: isDark,
                          onTap: () => _onTap(1),
                        ),

                        // Center placeholder for the elevated (+) button
                        const Expanded(child: SizedBox()),

                        // 3. Tasks (with dynamic red badge dot)
                        _buildNavItem(
                          icon: Icons.check_circle_outline_rounded,
                          isActive: currentIndex == 2 || currentIndex == 3,
                          isDark: isDark,
                          hasRedBadge: hasPendingTasks,
                          onTap: () => _onTap(2),
                        ),

                        // 4. Settings
                        _buildNavItem(
                          icon: Icons.settings_outlined,
                          isActive: currentIndex == 4,
                          isDark: isDark,
                          onTap: () => _onTap(4),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Center Elevated Quick Add (+) nestled smoothly inside the arched white dome
                Positioned(
                  top: 3,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _openQuickAdd(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white : const Color(0xFF111113),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.45)
                                : Colors.black.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                          width: 3.0,
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: isDark ? const Color(0xFF111113) : Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
    double iconSize = 22,
    bool hasRedBadge = false,
  }) {
    final activeTextColor = isDark ? Colors.white : Colors.black;
    final inactiveTextColor = isDark
        ? Colors.white.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.38);
    final activePillBg = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isActive ? activePillBg : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: isActive ? activeTextColor : inactiveTextColor,
                ),
                if (hasRedBadge)
                  Positioned(
                    top: -2,
                    right: -3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to generate curved nav bar path with center upward dome
Path getCurvedNavBarPath(Size size, {double topBaseline = 14, double cornerRadius = 27, double span = 46}) {
  final path = Path();
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final r = cornerRadius;
  final topY = topBaseline;

  // Start at top-left corner
  path.moveTo(r, topY);

  // Left straight baseline
  path.lineTo(cx - span, topY);

  // Smooth upward bell curve to dome apex (y = 0)
  path.cubicTo(
    cx - span * 0.55, topY,
    cx - span * 0.40, 0,
    cx, 0,
  );

  // Smooth downward bell curve from dome apex back to baseline
  path.cubicTo(
    cx + span * 0.40, 0,
    cx + span * 0.55, topY,
    cx + span, topY,
  );

  // Right straight baseline
  path.lineTo(w - r, topY);

  // Top-right rounded corner
  path.arcToPoint(Offset(w, topY + r), radius: Radius.circular(r));

  // Right edge
  path.lineTo(w, h - r);

  // Bottom-right rounded corner
  path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));

  // Bottom edge
  path.lineTo(r, h);

  // Bottom-left rounded corner
  path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));

  // Left edge
  path.lineTo(0, topY + r);

  // Top-left rounded corner
  path.arcToPoint(Offset(r, topY), radius: Radius.circular(r));

  path.close();
  return path;
}

class CurvedNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getCurvedNavBarPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CurvedNavBarPainter extends CustomPainter {
  final bool isDark;

  CurvedNavBarPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = getCurvedNavBarPath(size);

    // 1. Soft ambient shadow
    final shadowPaint1 = Paint()
      ..color = isDark ? Colors.black.withValues(alpha: 0.45) : const Color(0x18000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint1);

    final shadowPaint2 = Paint()
      ..color = isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint2);

    // 2. Glass gradient fill
    final rect = Offset.zero & size;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF28282C).withValues(alpha: 0.92),
                const Color(0xFF18181A).withValues(alpha: 0.82),
              ]
            : [
                Colors.white.withValues(alpha: 0.96),
                Colors.white.withValues(alpha: 0.88),
              ],
      ).createShader(rect);
    canvas.drawPath(path, fillPaint);

    // 3. Subtle stroke border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.90);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CurvedNavBarPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
