import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school.dart';
import 'school_repository.dart';

final class FirestoreSchoolRepository implements SchoolRepository {
  FirestoreSchoolRepository() : _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _schools =>
      _db.collection('schools');

  @override
  Future<List<School>> getSchools() async {
    // Single-field orderBy only — no composite index required.
    // Filtering `active` in Dart is safe because the schools collection
    // is always small (one entry per school).
    final snap = await _schools.orderBy('name').get();

    return snap.docs
        .map((doc) => School.fromDoc(doc))
        .where((s) => s.active)
        .toList();
  }

  @override
  Future<void> addSchool(School school) async {
    await _schools.add(school.toMap());
  }
}
