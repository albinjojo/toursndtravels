import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.initials,
    required this.colorIndex,
    this.radius = 28,
    this.fontSize = 17,
  });

  final String initials;
  final int colorIndex;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) =
        AppColors.avatarPalette[colorIndex % AppColors.avatarPalette.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initials,
        style: GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
