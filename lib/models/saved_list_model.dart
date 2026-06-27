import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_summary.dart';
import 'trip_type.dart';

class SavedListModel {
  const SavedListModel({
    required this.id,
    required this.schoolId,
    required this.name,
    this.filterGrade,
    this.filterDivision,
    this.filterToSchoolTrip,
    this.filterFromSchoolTrip,
    required this.students,
    required this.createdAt,
  });

  final String id;
  final String schoolId;
  final String name;
  final int? filterGrade;
  final String? filterDivision;
  final TripType? filterToSchoolTrip;
  final TripType? filterFromSchoolTrip;
  final List<StudentSummary> students;
  final DateTime createdAt;

  int get studentCount => students.length;

  factory SavedListModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String schoolId,
  ) {
    final data = doc.data()!;
    final rawStudents = (data['students'] as List<dynamic>?) ?? [];
    return SavedListModel(
      id: doc.id,
      schoolId: schoolId,
      name: (data['name'] as String?) ?? '',
      filterGrade: data['filterGrade'] as int?,
      filterDivision: data['filterDivision'] as String?,
      filterToSchoolTrip:
          TripType.fromString(data['filterToSchoolTrip'] as String?),
      filterFromSchoolTrip:
          TripType.fromString(data['filterFromSchoolTrip'] as String?),
      students: rawStudents
          .map((e) => StudentSummary.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'filterGrade': filterGrade,
        'filterDivision': filterDivision,
        'filterToSchoolTrip': filterToSchoolTrip?.label,
        'filterFromSchoolTrip': filterFromSchoolTrip?.label,
        'students': students.map((s) => s.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SavedListModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
