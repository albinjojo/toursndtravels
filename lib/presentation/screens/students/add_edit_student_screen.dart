import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/school.dart';
import '../../../models/student.dart';
import '../../../models/trip_type.dart';
import '../../../providers/student_providers.dart';

class AddEditStudentScreen extends ConsumerStatefulWidget {
  const AddEditStudentScreen({
    super.key,
    required this.school,
    this.student,
  });

  final School school;
  final Student? student;

  bool get isEdit => student != null;

  @override
  ConsumerState<AddEditStudentScreen> createState() =>
      _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends ConsumerState<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _fatherCtrl;
  late final TextEditingController _pickupCtrl;
  late final TextEditingController _phone1Ctrl;
  late final TextEditingController _phone2Ctrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  int _grade = 1;
  String _division = 'A';
  TripType? _toSchoolTrip;
  TripType? _fromSchoolTrip;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _nicknameCtrl = TextEditingController(text: s?.nickname ?? '');
    _fatherCtrl = TextEditingController(text: s?.fatherName ?? '');
    _pickupCtrl = TextEditingController(text: s?.pickupPoint ?? '');
    _phone1Ctrl = TextEditingController(text: s?.phone1 ?? '');
    _phone2Ctrl = TextEditingController(text: s?.phone2 ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _grade = s?.grade ?? 1;
    _division = s?.division ?? 'A';
    _toSchoolTrip = s?.toSchoolTrip;
    _fromSchoolTrip = s?.fromSchoolTrip;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _fatherCtrl.dispose();
    _pickupCtrl.dispose();
    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final repo = ref.read(studentRepositoryProvider);
    final now = DateTime.now();

    try {
      if (widget.isEdit) {
        final updated = widget.student!.copyWith(
          name: _nameCtrl.text.trim(),
          nickname: _nicknameCtrl.text.trim(),
          grade: _grade,
          division: _division,
          fatherName: _fatherCtrl.text.trim(),
          pickupPoint: _pickupCtrl.text.trim(),
          phone1: _phone1Ctrl.text.trim(),
          phone2: _phone2Ctrl.text.trim(),
          address: _addressCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          toSchoolTrip: _toSchoolTrip,
          fromSchoolTrip: _fromSchoolTrip,
          updatedAt: now,
        );
        await repo.updateStudent(updated);
      } else {
        final newStudent = Student(
          id: const Uuid().v4(),
          schoolId: widget.school.id,
          name: _nameCtrl.text.trim(),
          nickname: _nicknameCtrl.text.trim(),
          grade: _grade,
          division: _division,
          fatherName: _fatherCtrl.text.trim(),
          pickupPoint: _pickupCtrl.text.trim(),
          phone1: _phone1Ctrl.text.trim(),
          phone2: _phone2Ctrl.text.trim(),
          address: _addressCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          toSchoolTrip: _toSchoolTrip,
          fromSchoolTrip: _fromSchoolTrip,
          createdAt: now,
          updatedAt: now,
        );
        await repo.addStudent(newStudent);
      }

      ref.invalidate(studentsProvider(widget.school.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(title: widget.isEdit ? 'Edit Student' : 'Add Student'),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormField(
                        label: 'Student Name *',
                        controller: _nameCtrl,
                        isFocused: true,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: 'Nickname',
                        controller: _nicknameCtrl,
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: _DropdownField<int>(
                              label: 'Grade *',
                              value: _grade,
                              items: List.generate(12, (i) => i + 1),
                              display: (g) => 'Grade $g',
                              onChanged: (v) =>
                                  setState(() => _grade = v ?? _grade),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DropdownField<String>(
                              label: 'Division *',
                              value: _division,
                              items: const ['A', 'B', 'C', 'D', 'E'],
                              display: (d) => d,
                              onChanged: (v) =>
                                  setState(() => _division = v ?? _division),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: "Father Name",
                        controller: _fatherCtrl,
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: 'Pickup Point',
                        controller: _pickupCtrl,
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: 'Phone 1',
                        controller: _phone1Ctrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: 'Phone 2',
                        controller: _phone2Ctrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: 'Address',
                        controller: _addressCtrl,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 11),
                      _FormField(
                        label: 'Notes',
                        controller: _notesCtrl,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel('TRIP DETAILS'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DropdownField<TripType>(
                              label: 'To School',
                              value: _toSchoolTrip,
                              items: TripType.values,
                              display: (t) => t.label,
                              onChanged: (v) =>
                                  setState(() => _toSchoolTrip = v),
                              nullable: true,
                              nullLabel: 'None',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DropdownField<TripType>(
                              label: 'From School',
                              value: _fromSchoolTrip,
                              items: TripType.values,
                              display: (t) => t.label,
                              onChanged: (v) =>
                                  setState(() => _fromSchoolTrip = v),
                              nullable: true,
                              nullLabel: 'None',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            _BottomBar(
              isSaving: _isSaving,
              onSave: _save,
              onCancel: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _AppBar extends StatelessWidget {
  const _AppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textMedium, size: 22),
            onPressed: () => context.pop(),
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.isFocused = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool isFocused;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isFocused ? AppColors.primary : AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          autofocus: isFocused,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.roboto(
              fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: null,
            hintText: null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppColors.borderMedium, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.display,
    required this.onChanged,
    this.nullable = false,
    this.nullLabel = 'Any',
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) display;
  final void Function(T?) onChanged;
  final bool nullable;
  final String nullLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderMedium, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              value: value,
              isExpanded: true,
              style: GoogleFonts.roboto(
                  fontSize: 14, color: AppColors.textPrimary),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary, size: 18),
              items: [
                if (nullable)
                  DropdownMenuItem<T?>(
                    value: null,
                    child: Text(nullLabel,
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.textSecondary)),
                  ),
                ...items.map(
                  (item) => DropdownMenuItem<T?>(
                    value: item,
                    child: Text(display(item)),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          14, 12, 14, MediaQuery.of(context).padding.bottom + 14),
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Student'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
