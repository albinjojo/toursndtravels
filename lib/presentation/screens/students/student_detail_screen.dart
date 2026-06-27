import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/student.dart';
import '../../../providers/school_providers.dart';
import '../../../providers/student_providers.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/trip_badge.dart';

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(student: student),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                children: [
                  _TransportCard(student: student),
                  const SizedBox(height: 10),
                  _ContactCard(student: student),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ActionBar(student: student),
    );
  }
}

// ---------------------------------------------------------------------------
// Blue header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar row
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    'Student Details',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) => IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: () {
                      final school = ref.read(selectedSchoolProvider);
                      if (school != null) {
                        context.push(
                          '/students/${student.id}/edit',
                          extra: (school, student),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            // Avatar + name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withAlpha(51),
                    child: CircleAvatar(
                      radius: 31,
                      backgroundColor: Colors.white.withAlpha(31),
                      child: Text(
                        student.initials,
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    student.name,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Grade ${student.grade} · Division ${student.division}',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transport/Academic card
// ---------------------------------------------------------------------------

class _TransportCard extends StatelessWidget {
  const _TransportCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          if (student.nickname.isNotEmpty)
            InfoRowText(label: 'Nickname', value: student.nickname),
          InfoRowText(label: 'Pickup Point', value: student.pickupPoint),
          if (student.toSchoolTrip != null)
            InfoRow(
              label: 'To School Trip',
              child: TripBadge(type: student.toSchoolTrip!),
            ),
          if (student.fromSchoolTrip != null)
            InfoRow(
              label: 'From School Trip',
              isLast: true,
              child: TripBadge(type: student.fromSchoolTrip!),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact card
// ---------------------------------------------------------------------------

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          if (student.fatherName.isNotEmpty)
            InfoRowText(label: "Father's Name", value: student.fatherName),
          if (student.phone1.isNotEmpty) _PhoneRow(label: 'Phone 1', phone: student.phone1),
          if (student.phone2.isNotEmpty) _PhoneRow(label: 'Phone 2', phone: student.phone2),
          if (student.address.isNotEmpty) _MultiLineRow(label: 'Address', value: student.address),
          if (student.notes.isNotEmpty)
            _MultiLineRow(label: 'Notes', value: student.notes, isLast: true),
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.label, required this.phone});

  final String label;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.roboto(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 1),
              Text(
                phone,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _call(phone),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_rounded,
                  color: AppColors.success, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(String number) async {
    await launchUrl(Uri(scheme: 'tel', path: number));
  }
}

class _MultiLineRow extends StatelessWidget {
  const _MultiLineRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom action bar
// ---------------------------------------------------------------------------

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 12, 12, MediaQuery.of(context).padding.bottom + 14),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success),
              onPressed: () => _call(student.phone1),
              icon: const Icon(Icons.phone_rounded, size: 16),
              label: const Text('Call'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final school = ref.read(selectedSchoolProvider);
                if (school != null) {
                  context.push(
                    '/students/${student.id}/edit',
                    extra: (school, student),
                  );
                }
              },
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit'),
            ),
          ),
          const SizedBox(width: 8),
          _DeleteButton(student: student),
        ],
      ),
    );
  }

  Future<void> _call(String number) async {
    if (number.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: number));
  }
}

class _DeleteButton extends ConsumerWidget {
  const _DeleteButton({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _confirmDelete(context, ref),
      child: Container(
        width: 44,
        height: 44,
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
        title: const Text('Delete Student'),
        content: Text(
            'Remove ${student.name} permanently? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref
        .read(studentRepositoryProvider)
        .deleteStudent(student.schoolId, student.id);

    ref.invalidate(studentsProvider(student.schoolId));

    if (context.mounted) context.pop();
  }
}
