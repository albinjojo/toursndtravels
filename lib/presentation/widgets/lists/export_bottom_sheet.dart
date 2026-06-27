import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../../core/services/text_export_service.dart';
import '../../../models/saved_list_model.dart';

class ExportBottomSheet extends StatefulWidget {
  const ExportBottomSheet({
    super.key,
    required this.savedList,
    required this.schoolName,
  });

  final SavedListModel savedList;
  final String schoolName;

  static Future<void> show(
    BuildContext context, {
    required SavedListModel savedList,
    required String schoolName,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExportBottomSheet(
        savedList: savedList,
        schoolName: schoolName,
      ),
    );
  }

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

enum _ExportAction { pdf, text, copy }

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  _ExportAction? _loading;

  bool get _busy => _loading != null;

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  Future<void> _sharePdf() async {
    setState(() => _loading = _ExportAction.pdf);
    try {
      final bytes = await PdfExportService.generate(
        list: widget.savedList,
        schoolName: widget.schoolName,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${widget.savedList.name}.pdf',
      );
    } catch (e) {
      _showError('Could not generate PDF: $e');
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _shareText() async {
    setState(() => _loading = _ExportAction.text);
    try {
      final text = TextExportService.formatForWhatsApp(
        list: widget.savedList,
        schoolName: widget.schoolName,
      );
      await Share.share(text, subject: widget.savedList.name);
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _copyToClipboard() async {
    setState(() => _loading = _ExportAction.copy);
    try {
      final text = TextExportService.formatForWhatsApp(
        list: widget.savedList,
        schoolName: widget.schoolName,
      );
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('List copied to clipboard'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Export List',
            style: GoogleFonts.roboto(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.savedList.name,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 6),

          // Options
          _Option(
            icon: Icons.picture_as_pdf_rounded,
            iconBg: const Color(0xFFFFE4E6),
            iconColor: const Color(0xFFDC2626),
            title: 'Share as PDF',
            subtitle: 'Printable table — school name, filters, student list',
            loading: _loading == _ExportAction.pdf,
            disabled: _busy,
            onTap: _busy ? null : _sharePdf,
          ),
          _Option(
            icon: Icons.chat_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: 'Share as Text',
            subtitle: 'WhatsApp-ready formatted list',
            loading: _loading == _ExportAction.text,
            disabled: _busy,
            onTap: _busy ? null : _shareText,
          ),
          _Option(
            icon: Icons.copy_rounded,
            iconBg: AppColors.primaryBg,
            iconColor: AppColors.primary,
            title: 'Copy to Clipboard',
            subtitle: 'Paste the formatted list anywhere',
            loading: _loading == _ExportAction.copy,
            disabled: _busy,
            onTap: _busy ? null : _copyToClipboard,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single option row
// ---------------------------------------------------------------------------

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool loading;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = disabled && !loading
        ? AppColors.textTertiary
        : AppColors.textPrimary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading
            ? Padding(
                padding: const EdgeInsets.all(13),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
            : Icon(icon, color: disabled ? AppColors.textTertiary : iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }
}
