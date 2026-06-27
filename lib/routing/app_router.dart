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

final GoRouter appRouter = GoRouter(
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

    // Shell route: Students / Lists / Settings share a bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.students,
              builder: (_, _) => const StudentsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.lists,
              builder: (_, _) => const ListsHubScreen(),
            ),
          ],
        ),
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

    // Full-screen routes pushed on top of the shell
    GoRoute(
      path: AppRoutes.studentAdd,
      builder: (context, state) {
        final school = state.extra as School;
        return AddEditStudentScreen(school: school);
      },
    ),
    GoRoute(
      path: AppRoutes.studentDetail,
      builder: (context, state) {
        final student = state.extra as Student;
        return StudentDetailScreen(student: student);
      },
    ),
    GoRoute(
      path: AppRoutes.studentEdit,
      builder: (context, state) {
        final args = state.extra as (School, Student);
        return AddEditStudentScreen(school: args.$1, student: args.$2);
      },
    ),
    GoRoute(
      path: AppRoutes.listCreate,
      builder: (context, state) {
        final school = state.extra as School;
        return CreateListScreen(school: school);
      },
    ),
    GoRoute(
      path: AppRoutes.listView,
      builder: (context, state) {
        final list = state.extra as SavedListModel;
        return SavedListViewScreen(savedList: list);
      },
    ),
  ],
);
