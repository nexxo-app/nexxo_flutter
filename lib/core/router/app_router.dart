import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/widgets/bottom_nav_bar.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/education/education_screen.dart';
import '../../presentation/screens/education/admin/admin_panel_screen.dart';
import '../../presentation/screens/expenses/expenses_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/add_transaction_screen.dart';
import '../../presentation/screens/goals/savings_goals_screen.dart';
import '../../presentation/screens/goals/add_savings_goal_screen.dart';
import '../../data/models/supabase_models.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login', // Start at login for now
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) {
        final initialType = state.extra as String?;
        return AddTransactionScreen(initialType: initialType);
      },
    ),
    GoRoute(
      path: '/savings-goals',
      builder: (context, state) => const SavingsGoalsScreen(),
    ),
    GoRoute(
      path: '/add-savings-goal',
      builder: (context, state) {
        final goal = state.extra as SavingsGoal?;
        return AddSavingsGoalScreen(goal: goal);
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/education',
          builder: (context, state) => const EducationScreen(),
          routes: [
            GoRoute(
              path: 'admin',
              parentNavigatorKey:
                  _rootNavigatorKey, // Full screen, cover nav bar
              builder: (context, state) => const AdminPanelScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final loggingIn =
        state.uri.toString() == '/login' ||
        state.uri.toString() == '/register' ||
        state.uri.toString() == '/forgot-password';

    if (session == null && !loggingIn) {
      return '/login';
    }

    if (session != null && loggingIn) {
      return '/';
    }

    return null;
  },
);
