import 'package:cloud_firestore/cloud_firestore.dart';

class School {
  const School({
    required this.id,
    required this.name,
    required this.studentCount,
    required this.active,
    required this.colorIndex,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int studentCount;
  final bool active;
  final int colorIndex;
  final DateTime updatedAt;

  factory School.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return School(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      studentCount: (data['studentCount'] as int?) ?? 0,
      active: (data['active'] as bool?) ?? true,
      colorIndex: (data['colorIndex'] as int?) ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'studentCount': studentCount,
        'active': active,
        'colorIndex': colorIndex,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  School copyWith({
    String? id,
    String? name,
    int? studentCount,
    bool? active,
    int? colorIndex,
    DateTime? updatedAt,
  }) =>
      School(
        id: id ?? this.id,
        name: name ?? this.name,
        studentCount: studentCount ?? this.studentCount,
        active: active ?? this.active,
        colorIndex: colorIndex ?? this.colorIndex,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is School && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
