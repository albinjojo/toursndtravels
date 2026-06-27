import '../models/student.dart';

abstract interface class StudentRepository {
  Future<List<Student>> getStudents(String schoolId);

  Future<Student> getStudent(String schoolId, String studentId);

  Future<void> addStudent(Student student);

  Future<void> updateStudent(Student student);

  Future<void> deleteStudent(String schoolId, String studentId);
}
