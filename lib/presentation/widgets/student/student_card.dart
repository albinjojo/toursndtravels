import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/student.dart';
import '../common/trip_badge.dart';
import 'student_avatar.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: StudentAvatar(
                initials: student.initials,
                colorIndex: student.avatarColorIndex,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + grade badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          student.name,
                          style: GoogleFonts.roboto(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _GradeBadge(
                        grade: student.grade,
                        division: student.division,
                        colorIndex: student.avatarColorIndex,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Pickup point
                  Text(
                    student.pickupPoint,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Trip badges
                  Row(
                    children: [
                      if (student.toSchoolTrip != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: TripBadge(type: student.toSchoolTrip!),
                        ),
                      if (student.fromSchoolTrip != null)
                        TripBadge(type: student.fromSchoolTrip!),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.borderMedium,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({
    required this.grade,
    required this.division,
    required this.colorIndex,
  });

  final int grade;
  final String division;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) =
        AppColors.avatarPalette[colorIndex % AppColors.avatarPalette.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$grade · $division',
        style: GoogleFonts.roboto(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
