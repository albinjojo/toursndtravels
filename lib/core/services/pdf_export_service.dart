import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/saved_list_model.dart';
import '../../models/student_summary.dart';

abstract final class PdfExportService {
  static final _regular = pw.Font.helvetica();
  static final _bold = pw.Font.helveticaBold();

  static final _primary = PdfColor.fromHex('#1A6FC4');
  static final _textPrimary = PdfColor.fromHex('#111827');
  static final _textSecondary = PdfColor.fromHex('#6B7280');
  static final _textTertiary = PdfColor.fromHex('#9CA3AF');
  static final _border = PdfColor.fromHex('#E5E7EB');
  static final _rowAlt = PdfColor.fromHex('#F9FAFB');

  static Future<Uint8List> generate({
    required SavedListModel list,
    required String schoolName,
  }) async {
    final doc = pw.Document(
      title: list.name,
      author: 'Alphonsa Van Service',
    );

    final dateStr = DateFormat("d MMM yyyy 'at' hh:mm a").format(DateTime.now());
    final filterStr = _filterString(list);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        header: (ctx) => _header(list, schoolName, dateStr, filterStr),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          pw.SizedBox(height: 14),
          _table(list.students),
        ],
      ),
    );

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  static pw.Widget _header(
    SavedListModel list,
    String schoolName,
    String dateStr,
    String filterStr,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ALPHONSA VAN SERVICE',
                  style: pw.TextStyle(
                    font: _bold,
                    fontSize: 14,
                    color: _primary,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  schoolName,
                  style: pw.TextStyle(
                    font: _regular,
                    fontSize: 10,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            pw.Text(
              dateStr,
              style: pw.TextStyle(
                font: _regular,
                fontSize: 8,
                color: _textTertiary,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: _border, thickness: 0.5),
        pw.SizedBox(height: 8),
        pw.Text(
          list.name,
          style: pw.TextStyle(
            font: _bold,
            fontSize: 13,
            color: _textPrimary,
          ),
        ),
        pw.SizedBox(height: 3),
        if (filterStr.isNotEmpty)
          pw.Text(
            'Filters: $filterStr',
            style: pw.TextStyle(
              font: _regular,
              fontSize: 9,
              color: _textSecondary,
            ),
          ),
        if (filterStr.isNotEmpty) pw.SizedBox(height: 2),
        pw.Text(
          'Total: ${list.studentCount} student${list.studentCount == 1 ? '' : 's'}',
          style: pw.TextStyle(
            font: _bold,
            fontSize: 9,
            color: _textSecondary,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: _border, thickness: 0.5),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Alphonsa Van Service',
          style: pw.TextStyle(
            font: _regular,
            fontSize: 8,
            color: _textTertiary,
          ),
        ),
        pw.Text(
          'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: pw.TextStyle(
            font: _regular,
            fontSize: 8,
            color: _textTertiary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Student table
  // ---------------------------------------------------------------------------

  static pw.Widget _table(List<StudentSummary> students) {
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(24),   // #
        1: pw.FlexColumnWidth(2.5),   // Name
        2: pw.FixedColumnWidth(38),   // Grade
        3: pw.FixedColumnWidth(30),   // Div
        4: pw.FlexColumnWidth(2.0),   // Pickup Point
        5: pw.FixedColumnWidth(82),   // Phone
      },
      children: [
        _tableHeaderRow(),
        ...students.asMap().entries.map(
          (e) => _tableDataRow(e.key, e.value),
        ),
      ],
    );
  }

  static pw.TableRow _tableHeaderRow() {
    final style = pw.TextStyle(
      font: _bold,
      fontSize: 9,
      color: PdfColors.white,
    );
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: _primary),
      children: [
        _cell('#', style, align: pw.Alignment.center),
        _cell('Student Name', style),
        _cell('Grade', style, align: pw.Alignment.center),
        _cell('Div', style, align: pw.Alignment.center),
        _cell('Pickup Point', style),
        _cell('Phone', style),
      ],
    );
  }

  static pw.TableRow _tableDataRow(int index, StudentSummary s) {
    final style = pw.TextStyle(font: _regular, fontSize: 9, color: _textPrimary);
    final bg = index.isOdd ? _rowAlt : PdfColors.white;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        _cell('${index + 1}', style, align: pw.Alignment.center),
        _cell(s.name, style),
        _cell('${s.grade}', style, align: pw.Alignment.center),
        _cell(s.division, style, align: pw.Alignment.center),
        _cell(s.pickupPoint, style),
        _cell(s.phone1, style),
      ],
    );
  }

  static pw.Widget _cell(
    String text,
    pw.TextStyle style, {
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Align(
        alignment: align,
        child: pw.Text(text, style: style),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

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
