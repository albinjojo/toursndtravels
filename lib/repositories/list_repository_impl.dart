import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saved_list_model.dart';
import 'list_repository.dart';

final class FirestoreListRepository implements ListRepository {
  FirestoreListRepository() : _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _lists(String schoolId) =>
      _db.collection('schools').doc(schoolId).collection('lists');

  @override
  Future<List<SavedListModel>> getLists(String schoolId) async {
    final snap = await _lists(schoolId).orderBy('createdAt', descending: true).get();
    return snap.docs.map((doc) => SavedListModel.fromDoc(doc, schoolId)).toList();
  }

  @override
  Future<void> saveList(SavedListModel list) async {
    await _lists(list.schoolId).add(list.toMap());
  }

  @override
  Future<void> deleteList(String schoolId, String listId) async {
    await _lists(schoolId).doc(listId).delete();
  }
}
