import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trip_type.dart';
import '../../../providers/school_providers.dart';
import '../../../providers/student_providers.dart';
import '../../../routing/app_router.dart';
import '../../widgets/common/filter_chip_button.dart';
import '../../widgets/student/student_card.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final school = ref.watch(selectedSchoolProvider);
    if (school == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final studentsAsync = ref.watch(studentsProvider(school.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(schoolName: school.name),
            _FilterBar(),
            _SearchBar(),
            Expanded(
              child: studentsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => _ErrorBody(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(studentsProvider(school.id)),
                ),
                data: (_) => _StudentList(schoolId: school.id),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.studentAdd, extra: school),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _AppBar extends ConsumerWidget {
  const _AppBar({required this.schoolName});

  final String schoolName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 14, 6, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Students',
                  style: GoogleFonts.roboto(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.schools),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        schoolName,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: AppColors.textMedium, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(studentFiltersProvider);
    final notifier = ref.read(studentFiltersProvider.notifier);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          FilterChipButton(
            label: _gradeLabel(filters.grades),
            isActive: filters.grades.isNotEmpty,
            onTap: () => _pickGrades(context, filters.grades, notifier),
          ),
          const SizedBox(width: 7),
          FilterChipButton(
            label: _divisionLabel(filters.divisions),
            isActive: filters.divisions.isNotEmpty,
            onTap: () => _pickDivisions(context, filters.divisions, notifier),
          ),
          const SizedBox(width: 7),
          FilterChipButton(
            label: _tripLabel(filters.toSchoolTrips, 'To'),
            isActive: filters.toSchoolTrips.isNotEmpty,
            onTap: () => _pickTrips(
              context,
              'To School Trip',
              filters.toSchoolTrips,
              notifier.setToSchoolTrips,
            ),
          ),
          const SizedBox(width: 7),
          FilterChipButton(
            label: _tripLabel(filters.fromSchoolTrips, 'From'),
            isActive: filters.fromSchoolTrips.isNotEmpty,
            onTap: () => _pickTrips(
              context,
              'From School Trip',
              filters.fromSchoolTrips,
              notifier.setFromSchoolTrips,
            ),
          ),
        ],
      ),
    );
  }

  // Filter chip labels

  String _gradeLabel(Set<int> grades) {
    if (grades.isEmpty) return 'Grade';
    if (grades.length == 1) return 'Grade ${grades.first}';
    return 'Grades (${grades.length})';
  }

  String _divisionLabel(Set<String> divs) {
    if (divs.isEmpty) return 'Div';
    if (divs.length == 1) return 'Div ${divs.first}';
    return 'Divs (${divs.length})';
  }

  String _tripLabel(Set<TripType> trips, String prefix) {
    if (trips.isEmpty) return prefix;
    if (trips.length == 1) return '$prefix: ${trips.first.label}';
    return '$prefix (Both)';
  }

  // Picker launchers

  Future<void> _pickGrades(
    BuildContext context,
    Set<int> current,
    StudentFiltersNotifier notifier,
  ) async {
    final result = await MultiPickerSheet.show<int>(
      context: context,
      title: 'Select Grades',
      items: List.generate(12, (i) => i + 1),
      selected: current,
      label: (g) => 'Grade $g',
    );
    if (result != null) notifier.setGrades(result);
  }

  Future<void> _pickDivisions(
    BuildContext context,
    Set<String> current,
    StudentFiltersNotifier notifier,
  ) async {
    final result = await MultiPickerSheet.show<String>(
      context: context,
      title: 'Select Divisions',
      items: const ['A', 'B', 'C', 'D', 'E'],
      selected: current,
      label: (d) => 'Division $d',
    );
    if (result != null) notifier.setDivisions(result);
  }

  Future<void> _pickTrips(
    BuildContext context,
    String title,
    Set<TripType> current,
    void Function(Set<TripType>) setter,
  ) async {
    final result = await MultiPickerSheet.show<TripType>(
      context: context,
      title: title,
      items: TripType.values,
      selected: current,
      label: (t) => t.label,
    );
    if (result != null) setter(result);
  }
}

// ---------------------------------------------------------------------------
// Multi-select bottom sheet (checkbox rows)
// ---------------------------------------------------------------------------

/// Generic multi-select bottom sheet using CheckboxListTile.
/// Shows checkboxes so it is unambiguous that multiple items can be selected.
/// Returns null if dismissed without tapping Apply.
/// Returns an empty Set if Apply is tapped with no items selected (clears filter).
class MultiPickerSheet<T> extends StatefulWidget {
  const MultiPickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.label,
  });

  final String title;
  final List<T> items;
  final Set<T> selected;
  final String Function(T) label;

  /// Convenience launcher. Returns null on dismiss-without-apply.
  static Future<Set<T>?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required Set<T> selected,
    required String Function(T) label,
  }) {
    return showModalBottomSheet<Set<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => MultiPickerSheet<T>(
        title: title,
        items: items,
        selected: selected,
        label: label,
      ),
    );
  }

  @override
  State<MultiPickerSheet<T>> createState() => _MultiPickerSheetState<T>();
}

class _MultiPickerSheetState<T> extends State<MultiPickerSheet<T>> {
  // Mutable copy; toggled by checkboxes, returned on Apply.
  late Set<T> _selection;

  @override
  void initState() {
    super.initState();
    // initState runs exactly once per sheet opening — always fresh.
    _selection = Set<T>.from(widget.selected);
  }

  bool get _allSelected => _selection.length == widget.items.length;

  void _toggleItem(T item, bool? checked) {
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
    setState(() => _selection = <T>{});
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

        // Title row + Select All / Clear
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
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
                    fontSize: 14,
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
                    fontSize: 14,
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

        // Checkbox list — scrollable when items overflow
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
                onChanged: (v) => _toggleItem(item, v),
                title: Text(
                  widget.label(item),
                  style: GoogleFonts.roboto(
                    fontSize: 17,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                visualDensity:
                    const VisualDensity(horizontal: 0, vertical: 0),
              );
            },
          ),
        ),

        const Divider(height: 1, color: AppColors.borderLight),

        // Apply button — always visible at the bottom
        Padding(
          padding:
              EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _apply,
              child: Text(
                _selection.isEmpty
                    ? 'Clear Filter'
                    : 'Apply  (${_selection.length} selected)',
                style: GoogleFonts.roboto(
                  fontSize: 16,
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
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (q) =>
                    ref.read(studentFiltersProvider.notifier).setSearchQuery(q),
                style: GoogleFonts.roboto(
                    fontSize: 16, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  hintStyle: GoogleFonts.roboto(
                      fontSize: 16, color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Student list body
// ---------------------------------------------------------------------------

class _StudentList extends ConsumerWidget {
  const _StudentList({required this.schoolId});

  final String schoolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(filteredStudentsProvider(schoolId));

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: GoogleFonts.roboto(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 100),
      itemCount: students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentCard(
          student: student,
          onTap: () => context.push(
            '/students/${student.id}',
            extra: student,
          ),
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.roboto(
                  fontSize: 15, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
