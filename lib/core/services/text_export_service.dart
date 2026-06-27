import 'package:intl/intl.dart';

import '../../models/saved_list_model.dart';

abstract final class TextExportService {
  /// Formats the list for WhatsApp sharing.
  /// Uses *bold* Markdown supported by WhatsApp.
  static String formatForWhatsApp({
    required SavedListModel list,
    required String schoolName,
  }) {
    final buf = StringBuffer();
    final dateStr = DateFormat('d MMM yyyy').format(DateTime.now());

    buf.writeln('*${list.name}*');
    buf.writeln('🏫 $schoolName');
    buf.writeln('📅 $dateStr');

    final filters = _filterString(list);
    if (filters.isNotEmpty) buf.writeln('🔍 $filters');

    buf.writeln('👥 ${list.studentCount} students');
    buf.writeln('─' * 30);

    for (var i = 0; i < list.students.length; i++) {
      final s = list.students[i];
      buf.writeln();
      buf.writeln('${i + 1}. *${s.name}* (${s.grade}-${s.division})');
      buf.writeln('   📍 ${s.pickupPoint}');
      if (s.phone1.isNotEmpty) buf.writeln('   📞 ${s.phone1}');
    }

    return buf.toString().trimRight();
  }

  static String _filterString(SavedListModel list) {
    final parts = <String>[];
    if (list.filterGrade != null) parts.add('Grade ${list.filterGrade}');
    if (list.filterDivision != null) parts.add('Div ${list.filterDivision}');
    if (list.filterToSchoolTrip != null) {
      parts.add('To school: ${list.filterToSchoolTrip!.label}');
    }
    if (list.filterFromSchoolTrip != null) {
      parts.add('From school: ${list.filterFromSchoolTrip!.label}');
    }
    return parts.join(' · ');
  }
}
