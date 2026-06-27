import '../models/school.dart';

abstract interface class SchoolRepository {
  /// Returns only active schools, sorted by name.
  Future<List<School>> getSchools();

  Future<void> addSchool(School school);
}
