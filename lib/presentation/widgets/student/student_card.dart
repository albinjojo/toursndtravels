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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar — ~48dp diameter
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: StudentAvatar(
                initials: student.initials,
                colorIndex: student.avatarColorIndex,
                radius: 24,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row — Flexible prevents overflow against the badge
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
                  // Pickup point
                  Text(
                    student.pickupPoint,
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Trip badges — Wrap avoids overflow when both are present
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
            const SizedBox(width: 4),
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

/// Shared grade + division badge — used on Students page and Create List page.
class GradeBadge extends StatelessWidget {
  const GradeBadge({
    super.key,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        'Grade $grade • $division',
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
