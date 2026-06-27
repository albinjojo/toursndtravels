import 'student.dart';

/// Lightweight snapshot stored inside a SavedListModel document.
class StudentSummary {
  const StudentSummary({
    required this.id,
    required this.name,
    required this.grade,
    required this.division,
    required this.pickupPoint,
    required this.phone1,
  });

  final String id;
  final String name;
  final int grade;
  final String division;
  final String pickupPoint;
  final String phone1;

  factory StudentSummary.fromStudent(Student s) => StudentSummary(
        id: s.id,
        name: s.name,
        grade: s.grade,
        division: s.division,
        pickupPoint: s.pickupPoint,
        phone1: s.phone1,
      );

  factory StudentSummary.fromMap(Map<String, dynamic> m) => StudentSummary(
        id: (m['id'] as String?) ?? '',
        name: (m['name'] as String?) ?? '',
        grade: (m['grade'] as int?) ?? 0,
        division: (m['division'] as String?) ?? '',
        pickupPoint: (m['pickupPoint'] as String?) ?? '',
        phone1: (m['phone1'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'grade': grade,
        'division': division,
        'pickupPoint': pickupPoint,
        'phone1': phone1,
      };
}
