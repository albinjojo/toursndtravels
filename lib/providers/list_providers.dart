import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_list_model.dart';
import '../repositories/list_repository.dart';
import '../repositories/list_repository_impl.dart';

final listRepositoryProvider = Provider<ListRepository>(
  (_) => FirestoreListRepository(),
);

final savedListsProvider =
    FutureProvider.family<List<SavedListModel>, String>((ref, schoolId) {
  return ref.read(listRepositoryProvider).getLists(schoolId);
});
