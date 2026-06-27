import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_type.dart';

class Student {
  const Student({
    required this.id,
    required this.schoolId,
    required this.name,
    this.nickname = '',
    required this.grade,
    required this.division,
    this.fatherName = '',
    this.pickupPoint = '',
    this.phone1 = '',
    this.phone2 = '',
    this.address = '',
    this.notes = '',
    this.toSchoolTrip,
    this.fromSchoolTrip,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String schoolId;
  final String name;
  final String nickname;
  final int grade;
  final String division;
  final String fatherName;
  final String pickupPoint;
  final String phone1;
  final String phone2;
  final String address;
  final String notes;
  final TripType? toSchoolTrip;
  final TripType? fromSchoolTrip;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  int get _avatarIndex =>
      name.codeUnits.fold(0, (a, b) => a + b) % 4;

  int get avatarColorIndex => _avatarIndex;

  factory Student.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, String schoolId) {
    final data = doc.data()!;
    return Student(
      id: doc.id,
      schoolId: schoolId,
      name: (data['name'] as String?) ?? '',
      nickname: (data['nickname'] as String?) ?? '',
      grade: (data['grade'] as int?) ?? 1,
      division: (data['division'] as String?) ?? '',
      fatherName: (data['fatherName'] as String?) ?? '',
      pickupPoint: (data['pickupPoint'] as String?) ?? '',
      phone1: (data['phone1'] as String?) ?? '',
      phone2: (data['phone2'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      notes: (data['notes'] as String?) ?? '',
      toSchoolTrip: TripType.fromString(data['toSchoolTrip'] as String?),
      fromSchoolTrip: TripType.fromString(data['fromSchoolTrip'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nickname': nickname,
        'grade': grade,
        'division': division,
        'fatherName': fatherName,
        'pickupPoint': pickupPoint,
        'phone1': phone1,
        'phone2': phone2,
        'address': address,
        'notes': notes,
        'toSchoolTrip': toSchoolTrip?.label,
        'fromSchoolTrip': fromSchoolTrip?.label,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Student copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? nickname,
    int? grade,
    String? division,
    String? fatherName,
    String? pickupPoint,
    String? phone1,
    String? phone2,
    String? address,
    String? notes,
    Object? toSchoolTrip = _sentinel,
    Object? fromSchoolTrip = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Student(
        id: id ?? this.id,
        schoolId: schoolId ?? this.schoolId,
        name: name ?? this.name,
        nickname: nickname ?? this.nickname,
        grade: grade ?? this.grade,
        division: division ?? this.division,
        fatherName: fatherName ?? this.fatherName,
        pickupPoint: pickupPoint ?? this.pickupPoint,
        phone1: phone1 ?? this.phone1,
        phone2: phone2 ?? this.phone2,
        address: address ?? this.address,
        notes: notes ?? this.notes,
        toSchoolTrip: toSchoolTrip == _sentinel
            ? this.toSchoolTrip
            : toSchoolTrip as TripType?,
        fromSchoolTrip: fromSchoolTrip == _sentinel
            ? this.fromSchoolTrip
            : fromSchoolTrip as TripType?,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Student && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

const _sentinel = Object();
