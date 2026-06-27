import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/saved_list_model.dart';
import '../../../models/school.dart';
import '../../../models/student.dart';
import '../../../models/student_summary.dart';
import '../../../models/trip_type.dart';
import '../../../providers/list_providers.dart';
import '../../../providers/student_providers.dart';
import '../../widgets/student/student_avatar.dart';
import '../../widgets/student/student_card.dart';
import '../../widgets/common/trip_badge.dart';

// ---------------------------------------------------------------------------
// Grade helpers (grades -2=LKG, -1=UKG, 1–10)
// ---------------------------------------------------------------------------

const _kGradeValues = [-2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

String _gradeLabel(int g) => switch (g) {
      -2 => 'LKG',
      -1 => 'UKG',
      _ => 'Grade $g',
    };

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CreateListScreen extends ConsumerStatefulWidget {
  const CreateListScreen({super.key, required this.school});

  final School school;

  @override
  ConsumerState<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends ConsumerState<CreateListScreen> {
  final _nameCtrl = TextEditingController();
  bool _isSaving = false;

  // All four filters are now multi-select Sets.
  // An empty Set means "no filter applied for this category".
  Set<int> _filterGrades = {};
  Set<String> _filterDivisions = {};
  Set<TripType> _filterToSchool = {};
  Set<TripType> _filterFromSchool = {};

  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Filtering — AND across categories, OR within each category
  // ---------------------------------------------------------------------------

  List<Student> _applyFilters(List<Student> all) {
    return all.where((s) {
      if (_filterGrades.isNotEmpty && !_filterGrades.contains(s.grade)) {
        return false;
      }
      if (_filterDivisions.isNotEmpty &&
          !_filterDivisions.contains(s.division)) {
        return false;
      }
      if (_filterToSchool.isNotEmpty &&
          !_filterToSchool.contains(s.toSchoolTrip)) {
        return false;
      }
      if (_filterFromSchool.isNotEmpty &&
          !_filterFromSchool.contains(s.fromSchoolTrip)) {
        return false;
      }
      return true;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save(List<Student> filtered) async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a list name')),
      );
      return;
    }
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one student')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final selected = filtered
        .where((s) => _selectedIds.contains(s.id))
        .map(StudentSummary.fromStudent)
        .toList();

    // SavedListModel stores a single value per filter field.
    // Persist only when exactly one value is selected; null otherwise.
    final list = SavedListModel(
      id: '',
      schoolId: widget.school.id,
      name: _nameCtrl.text.trim(),
      filterGrade: _filterGrades.length == 1 ? _filterGrades.first : null,
      filterDivision:
          _filterDivisions.length == 1 ? _filterDivisions.first : null,
      filterToSchoolTrip:
          _filterToSchool.length == 1 ? _filterToSchool.first : null,
      filterFromSchoolTrip:
          _filterFromSchool.length == 1 ? _filterFromSchool.first : null,
      students: selected,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(listRepositoryProvider).saveList(list);
      ref.invalidate(savedListsProvider(widget.school.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsProvider(widget.school.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: studentsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (all) {
            final filtered = _applyFilters(all);
            return Column(
              children: [
                // App bar
                Container(
                  color: AppColors.surface,
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textMedium, size: 22),
                        onPressed: () => context.pop(),
                      ),
                      Text(
                        'Create List',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // List name
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'List Name',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _nameCtrl,
                        autofocus: true,
                        style: GoogleFonts.roboto(
                            fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. Monday Route',
                          hintStyle: GoogleFonts.roboto(
                              color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter grid — all four use the same multi-select cell
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FILTER STUDENTS',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MultiFilterCell<int>(
                            cellLabel: 'Grade',
                            selected: _filterGrades,
                            summaryOf: (s) {
                              if (s.isEmpty) return 'All';
                              if (s.length == 1) {
                                return _gradeLabel(s.first);
                              }
                              return 'Grade (${s.length})';
                            },
                            onTap: () => _pickGrades(context),
                          ),
                          const SizedBox(width: 8),
                          _MultiFilterCell<String>(
                            cellLabel: 'Division',
                            selected: _filterDivisions,
                            summaryOf: (s) {
                              if (s.isEmpty) return 'All';
                              if (s.length == 1) return 'Div ${s.first}';
                              return 'Divs (${s.length})';
                            },
                            onTap: () => _pickDivisions(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MultiFilterCell<TripType>(
                            cellLabel: 'Morning',
                            selected: _filterToSchool,
                            summaryOf: (s) {
                              if (s.isEmpty) return 'All';
                              if (s.length == 1) {
                                return s.first == TripType.first
                                    ? 'First'
                                    : 'Second';
                              }
                              return 'Both';
                            },
                            onTap: () => _pickToSchool(context),
                          ),
                          const SizedBox(width: 8),
                          _MultiFilterCell<TripType>(
                            cellLabel: 'Evening',
                            selected: _filterFromSchool,
                            summaryOf: (s) {
                              if (s.isEmpty) return 'All';
                              if (s.length == 1) {
                                return s.first == TripType.first
                                    ? 'First'
                                    : 'Second';
                              }
                              return 'Both';
                            },
                            onTap: () => _pickFromSchool(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Students header + select all
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  child: Row(
                    children: [
                      Text(
                        'Students (${filtered.length})',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          if (_selectedIds.length == filtered.length) {
                            _selectedIds.clear();
                          } else {
                            _selectedIds.addAll(filtered.map((s) => s.id));
                          }
                        }),
                        child: Row(
                          children: [
                            _Checkbox(
                              checked: filtered.isNotEmpty &&
                                  _selectedIds.length == filtered.length,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Select All',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Student rows
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No students match the filters',
                            style: GoogleFonts.roboto(
                                color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final checked = _selectedIds.contains(s.id);
                            return _StudentRow(
                              student: s,
                              checked: checked,
                              onToggle: () => setState(() {
                                if (checked) {
                                  _selectedIds.remove(s.id);
                                } else {
                                  _selectedIds.add(s.id);
                                }
                              }),
                            );
                          },
                        ),
                ),

                // Save button
                Container(
                  color: AppColors.surface,
                  padding: EdgeInsets.fromLTRB(
                      12,
                      10,
                      12,
                      MediaQuery.of(context).padding.bottom + 14),
                  child: SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _save(filtered),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded, size: 18),
                      label: Text(
                          'Save List (${_selectedIds.length} selected)'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Picker launchers — all delegate to the single _showMultiPicker helper
  // ---------------------------------------------------------------------------

  Future<void> _pickGrades(BuildContext context) async {
    final result = await _showMultiPicker<int>(
      context: context,
      title: 'Select Grades',
      items: _kGradeValues,
      selected: _filterGrades,
      itemLabel: _gradeLabel,
    );
    if (result != null) setState(() => _filterGrades = result);
  }

  Future<void> _pickDivisions(BuildContext context) async {
    final result = await _showMultiPicker<String>(
      context: context,
      title: 'Select Divisions',
      items: const ['A', 'B', 'C', 'D', 'E'],
      selected: _filterDivisions,
      itemLabel: (d) => 'Division $d',
    );
    if (result != null) setState(() => _filterDivisions = result);
  }

  Future<void> _pickToSchool(BuildContext context) async {
    final result = await _showMultiPicker<TripType>(
      context: context,
      title: 'Morning',
      items: TripType.values,
      selected: _filterToSchool,
      itemLabel: (t) => t.label,
    );
    if (result != null) setState(() => _filterToSchool = result);
  }

  Future<void> _pickFromSchool(BuildContext context) async {
    final result = await _showMultiPicker<TripType>(
      context: context,
      title: 'Evening',
      items: TripType.values,
      selected: _filterFromSchool,
      itemLabel: (t) => t.label,
    );
    if (result != null) setState(() => _filterFromSchool = result);
  }

  Future<Set<T>?> _showMultiPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required Set<T> selected,
    required String Function(T) itemLabel,
  }) {
    return showModalBottomSheet<Set<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MultiPickerSheet<T>(
        title: title,
        items: items,
        selected: selected,
        itemLabel: itemLabel,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic multi-select filter cell
// ---------------------------------------------------------------------------

class _MultiFilterCell<T> extends StatelessWidget {
  const _MultiFilterCell({
    required this.cellLabel,
    required this.selected,
    required this.summaryOf,
    required this.onTap,
  });

  final String cellLabel;
  final Set<T> selected;
  final String Function(Set<T>) summaryOf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected.isNotEmpty;
    final display = summaryOf(selected);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cellLabel,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryBg : AppColors.surface,
                border: Border.all(
                  color: active ? AppColors.primary : AppColors.borderMedium,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color:
                        active ? AppColors.primary : AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic multi-select picker sheet (used by ALL four filters)
// ---------------------------------------------------------------------------

class _MultiPickerSheet<T> extends StatefulWidget {
  const _MultiPickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.itemLabel,
  });

  final String title;
  final List<T> items;
  final Set<T> selected;
  final String Function(T) itemLabel;

  @override
  State<_MultiPickerSheet<T>> createState() => _MultiPickerSheetState<T>();
}

class _MultiPickerSheetState<T> extends State<_MultiPickerSheet<T>> {
  late Set<T> _selection;

  @override
  void initState() {
    super.initState();
    // initState runs exactly once per sheet open — always a fresh copy.
    _selection = Set<T>.from(widget.selected);
  }

  bool get _allSelected => _selection.length == widget.items.length;

  void _toggle(T item, bool? checked) {
    setState(() {
      if (checked == true) {
        _selection.add(item);
      } else {
        _selection.remove(item);
      }
    });
  }

  void _selectAll() {
    setState(() => _selection = Set<T>.from(widget.items));
  }

  void _clearAll() {
    setState(() => _selection = {});
  }

  void _apply() {
    Navigator.of(context).pop(Set<T>.from(_selection));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderMedium,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),

        // Title + Select All / Clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _allSelected ? null : _selectAll,
                child: Text(
                  'Select All',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _allSelected
                        ? AppColors.textTertiary
                        : AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: _selection.isEmpty ? null : _clearAll,
                child: Text(
                  'Clear',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selection.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AppColors.borderLight),

        // Checkbox list — scrollable for long lists (e.g. 12 grades)
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.48,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: widget.items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (_, i) {
              final item = widget.items[i];
              final checked = _selection.contains(item);
              return CheckboxListTile(
                value: checked,
                onChanged: (v) => _toggle(item, v),
                title: Text(
                  widget.itemLabel(item),
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight:
                        checked ? FontWeight.w600 : FontWeight.w400,
                    color: checked
                        ? AppColors.textPrimary
                        : AppColors.textMedium,
                  ),
                ),
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 2),
              );
            },
          ),
        ),

        const Divider(height: 1, color: AppColors.borderLight),

        // Apply — only this button closes the sheet
        Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              child: Text(
                _selection.isEmpty
                    ? 'Clear Filter'
                    : 'Apply  (${_selection.length} selected)',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Student row sub-widgets (unchanged)
// ---------------------------------------------------------------------------

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: checked ? AppColors.primary : AppColors.borderMedium,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.checked,
    required this.onToggle,
  });

  final Student student;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        color: checked
            ? AppColors.successBg.withAlpha(128)
            : AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _Checkbox(checked: checked),
            ),
            const SizedBox(width: 12),
            // Avatar — ~44dp diameter
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: StudentAvatar(
                initials: student.initials,
                colorIndex: student.avatarColorIndex,
                radius: 22,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),
            // Student details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + grade badge — Flexible prevents badge-induced overflow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          student.name,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GradeBadge(
                        grade: student.grade,
                        division: student.division,
                        colorIndex: student.avatarColorIndex,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.pickupPoint,
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Trip badges — Wrap handles overflow when both are shown
                  if (student.toSchoolTrip != null ||
                      student.fromSchoolTrip != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (student.toSchoolTrip != null)
                          TripBadge(
                            type: student.toSchoolTrip!,
                            direction: 'Morning',
                          ),
                        if (student.fromSchoolTrip != null)
                          TripBadge(
                            type: student.fromSchoolTrip!,
                            direction: 'Evening',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
