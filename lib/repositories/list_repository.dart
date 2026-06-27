import '../models/saved_list_model.dart';

abstract interface class ListRepository {
  Future<List<SavedListModel>> getLists(String schoolId);

  Future<void> saveList(SavedListModel list);

  Future<void> deleteList(String schoolId, String listId);
}
