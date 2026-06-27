import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trip_type.dart';

class TripBadge extends StatelessWidget {
  const TripBadge({super.key, required this.type, this.small = false});

  final TripType type;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      TripType.first => (AppColors.firstTripBg, AppColors.firstTripText),
      TripType.second => (AppColors.secondTripBg, AppColors.secondTripText),
    };
    final label = switch (type) {
      TripType.first => '↑ FIRST',
      TripType.second => '↓ SECOND',
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 5 : 7,
        vertical: small ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(small ? 4 : 6),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: small ? 8 : 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
