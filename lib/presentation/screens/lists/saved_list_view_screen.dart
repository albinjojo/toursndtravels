import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/saved_list_model.dart';
import '../../../models/student_summary.dart';
import '../../../providers/list_providers.dart';
import '../../../providers/school_providers.dart';
import '../../widgets/lists/export_bottom_sheet.dart';

class SavedListViewScreen extends ConsumerWidget {
  const SavedListViewScreen({super.key, required this.savedList});

  final SavedListModel savedList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(savedList: savedList),
            _SummaryChips(savedList: savedList),
            Expanded(child: _StudentRows(students: savedList.students)),
            _ActionBar(savedList: savedList),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.savedList});

  final SavedListModel savedList;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textMedium, size: 22),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  savedList.name,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${savedList.studentCount} students',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary chips
// ---------------------------------------------------------------------------

class _SummaryChips extends StatelessWidget {
  const _SummaryChips({required this.savedList});

  final SavedListModel savedList;

  @override
  Widget build(BuildContext context) {
    final chips = <(String, Color, Color)>[];

    if (savedList.filterGrade != null) {
      chips.add(('Grade ${savedList.filterGrade}', AppColors.navActiveBg,
          AppColors.primary));
    }
    if (savedList.filterToSchoolTrip != null) {
      chips.add(('↑ ${savedList.filterToSchoolTrip!.label} trip',
          AppColors.firstTripBg, AppColors.firstTripText));
    }
    if (savedList.filterFromSchoolTrip != null) {
      chips.add(('↓ ${savedList.filterFromSchoolTrip!.label} trip',
          AppColors.secondTripBg, AppColors.secondTripText));
    }
    if (savedList.filterDivision != null) {
      chips.add(('Div ${savedList.filterDivision}', AppColors.navActiveBg,
          AppColors.primary));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: c.$2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      c.$1,
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c.$3,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Student rows
// ---------------------------------------------------------------------------

class _StudentRows extends StatelessWidget {
  const _StudentRows({required this.students});

  final List<StudentSummary> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: students.length,
        separatorBuilder: (_, _) =>
            const Divider(color: AppColors.borderLight, height: 1),
        itemBuilder: (context, index) {
          final s = students[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Grade ${s.grade} · ${s.pickupPoint} · ${s.phone1}',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action bar
// ---------------------------------------------------------------------------

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.savedList});

  final SavedListModel savedList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
          10, 10, 10, MediaQuery.of(context).padding.bottom + 14),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final school = ref.read(selectedSchoolProvider);
                ExportBottomSheet.show(
                  context,
                  savedList: savedList,
                  schoolName: school?.name ?? '',
                );
              },
              icon: const Icon(Icons.upload_rounded, size: 15),
              label: const Text('Export'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Editing lists coming soon')),
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 15),
              label: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 8),
          _DeleteButton(savedList: savedList),
        ],
      ),
    );
  }
}

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton({required this.savedList});

  final SavedListModel savedList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _confirmDelete(context, ref),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 20),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Delete "${savedList.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final school = ref.read(selectedSchoolProvider);
    if (school == null) return;

    await ref
        .read(listRepositoryProvider)
        .deleteList(school.id, savedList.id);
    ref.invalidate(savedListsProvider(school.id));

    if (context.mounted) context.pop();
  }
}
