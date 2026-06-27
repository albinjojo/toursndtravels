import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/school.dart';
import '../models/student.dart';
import '../models/saved_list_model.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/school_selection/school_selection_screen.dart';
import '../presentation/screens/home/home_shell.dart';
import '../presentation/screens/students/students_screen.dart';
import '../presentation/screens/students/student_detail_screen.dart';
import '../presentation/screens/students/add_edit_student_screen.dart';
import '../presentation/screens/lists/lists_hub_screen.dart';
import '../presentation/screens/lists/create_list_screen.dart';
import '../presentation/screens/lists/saved_list_view_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const schools = '/schools';
  static const students = '/students';
  static const studentAdd = '/students/add';
  static const studentDetail = '/students/:id';
  static const studentEdit = '/students/:id/edit';
  static const lists = '/lists';
  static const listCreate = '/lists/create';
  static const listView = '/lists/:id';
  static const settings = '/settings';
}

// Root navigator key — passed to every full-screen sub-route via
// parentNavigatorKey so those pages land on the root Navigator instead of
// inside a StatefulShellRoute branch navigator. This is required for the
// Android system back button to pop them correctly rather than exiting the
// app, because StatefulShellRoute registers a ChildBackButtonDispatcher per
// branch that intercepts back before the root dispatcher can handle it.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.schools,
      builder: (_, _) => const SchoolSelectionScreen(),
    ),

    // Shell route: Students / Lists / Settings share a bottom nav.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        // ── Students branch ──────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.students,
              builder: (_, _) => const StudentsScreen(),
              routes: [
                // Add student — parentNavigatorKey puts this on the root
                // Navigator so it renders full-screen without the bottom nav.
                GoRoute(
                  path: 'add',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final school = state.extra as School;
                    return AddEditStudentScreen(school: school);
                  },
                ),
                // Student detail — full-screen on root Navigator.
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final student = state.extra as Student;
                    return StudentDetailScreen(student: student);
                  },
                ),
                // Edit student — flattened as a sibling of ':id' rather than
                // nested inside it. go_router requires that a route with
                // parentNavigatorKey be a leaf (no sub-routes), so 'edit'
                // cannot be a child of ':id'. The full resolved path is still
                // /students/:id/edit, matching AppRoutes.studentEdit.
                GoRoute(
                  path: ':id/edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final args = state.extra as (School, Student);
                    return AddEditStudentScreen(school: args.$1, student: args.$2);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Lists branch ─────────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.lists,
              builder: (_, _) => const ListsHubScreen(),
              routes: [
                // Create list — full-screen on root Navigator.
                GoRoute(
                  path: 'create',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final school = state.extra as School;
                    return CreateListScreen(school: school);
                  },
                ),
                // View saved list — full-screen on root Navigator.
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final list = state.extra as SavedListModel;
                    return SavedListViewScreen(savedList: list);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Settings branch ───────────────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
