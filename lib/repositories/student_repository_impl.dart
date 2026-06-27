import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import 'student_repository.dart';

final class FirestoreStudentRepository implements StudentRepository {
  FirestoreStudentRepository() : _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _students(String schoolId) =>
      _db.collection('schools').doc(schoolId).collection('students');

  @override
  Future<List<Student>> getStudents(String schoolId) async {
    final snap =
        await _students(schoolId).orderBy('name').get();
    return snap.docs.map((doc) => Student.fromDoc(doc, schoolId)).toList();
  }

  @override
  Future<Student> getStudent(String schoolId, String studentId) async {
    final doc = await _students(schoolId).doc(studentId).get();
    if (!doc.exists) throw StateError('Student $studentId not found');
    return Student.fromDoc(doc, schoolId);
  }

  @override
  Future<void> addStudent(Student student) async {
    final data = student.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _students(student.schoolId).add(data);

    // Increment school student count
    await _db.collection('schools').doc(student.schoolId).update({
      'studentCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> updateStudent(Student student) async {
    await _students(student.schoolId).doc(student.id).update(student.toMap());
  }

  @override
  Future<void> deleteStudent(String schoolId, String studentId) async {
    await _students(schoolId).doc(studentId).delete();
    await _db.collection('schools').doc(schoolId).update({
      'studentCount': FieldValue.increment(-1),
    });
  }
}
