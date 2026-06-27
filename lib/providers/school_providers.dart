import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/school.dart';
import '../repositories/school_repository.dart';
import '../repositories/school_repository_impl.dart';

final schoolRepositoryProvider = Provider<SchoolRepository>(
  (_) => FirestoreSchoolRepository(),
);

final schoolsProvider = FutureProvider<List<School>>((ref) {
  return ref.read(schoolRepositoryProvider).getSchools();
});

final selectedSchoolProvider = StateProvider<School?>((ref) => null);
