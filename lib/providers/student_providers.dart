import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/trip_type.dart';
import '../repositories/student_repository.dart';
import '../repositories/student_repository_impl.dart';

final studentRepositoryProvider = Provider<StudentRepository>(
  (_) => FirestoreStudentRepository(),
);

// Fetch all students for a given school.
final studentsProvider =
    FutureProvider.family<List<Student>, String>((ref, schoolId) {
  return ref.read(studentRepositoryProvider).getStudents(schoolId);
});

// ---------------------------------------------------------------------------
// Filter state — multi-select per category
// ---------------------------------------------------------------------------

class StudentFilters {
  const StudentFilters({
    this.grades = const {},
    this.divisions = const {},
    this.toSchoolTrips = const {},
    this.fromSchoolTrips = const {},
    this.searchQuery = '',
  });

  final Set<int> grades;
  final Set<String> divisions;
  final Set<TripType> toSchoolTrips;
  final Set<TripType> fromSchoolTrips;
  final String searchQuery;

  bool get hasActive =>
      grades.isNotEmpty ||
      divisions.isNotEmpty ||
      toSchoolTrips.isNotEmpty ||
      fromSchoolTrips.isNotEmpty ||
      searchQuery.isNotEmpty;

  /// Within each active category, student must match ANY selected value.
  /// Across categories, ALL active categories must match (AND logic).
  bool matches(Student s) {
    if (grades.isNotEmpty && !grades.contains(s.grade)) return false;
    if (divisions.isNotEmpty && !divisions.contains(s.division)) return false;
    if (toSchoolTrips.isNotEmpty &&
        !toSchoolTrips.contains(s.toSchoolTrip)) {
      return false;
    }
    if (fromSchoolTrips.isNotEmpty &&
        !fromSchoolTrips.contains(s.fromSchoolTrip)) {
      return false;
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      if (!s.name.toLowerCase().contains(q) &&
          !s.pickupPoint.toLowerCase().contains(q)) {
        return false;
      }
    }
    return true;
  }

  StudentFilters copyWith({
    Set<int>? grades,
    Set<String>? divisions,
    Set<TripType>? toSchoolTrips,
    Set<TripType>? fromSchoolTrips,
    String? searchQuery,
  }) =>
      StudentFilters(
        grades: grades ?? this.grades,
        divisions: divisions ?? this.divisions,
        toSchoolTrips: toSchoolTrips ?? this.toSchoolTrips,
        fromSchoolTrips: fromSchoolTrips ?? this.fromSchoolTrips,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  static const StudentFilters empty = StudentFilters();
}

class StudentFiltersNotifier extends Notifier<StudentFilters> {
  @override
  StudentFilters build() => StudentFilters.empty;

  void setGrades(Set<int> grades) =>
      state = state.copyWith(grades: grades);
  void setDivisions(Set<String> divisions) =>
      state = state.copyWith(divisions: divisions);
  void setToSchoolTrips(Set<TripType> trips) =>
      state = state.copyWith(toSchoolTrips: trips);
  void setFromSchoolTrips(Set<TripType> trips) =>
      state = state.copyWith(fromSchoolTrips: trips);
  void setSearchQuery(String q) =>
      state = state.copyWith(searchQuery: q);
  void clearAll() => state = StudentFilters.empty;
}

final studentFiltersProvider =
    NotifierProvider<StudentFiltersNotifier, StudentFilters>(
  StudentFiltersNotifier.new,
);

final filteredStudentsProvider =
    Provider.family<List<Student>, String>((ref, schoolId) {
  final async = ref.watch(studentsProvider(schoolId));
  final filters = ref.watch(studentFiltersProvider);
  return async.when(
    data: (list) => filters.hasActive
        ? list.where(filters.matches).toList()
        : list,
    loading: () => [],
    error: (_, _) => [],
  );
});
