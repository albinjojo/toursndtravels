import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/trip_type.dart';

class TripBadge extends StatelessWidget {
  const TripBadge({
    super.key,
    required this.type,
    this.small = false,
    // When provided, shows "🚌 {direction}: FIRST/SECOND".
    // When omitted, shows the directional arrow format.
    this.direction,
  });

  final TripType type;
  final bool small;
  final String? direction;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      TripType.first => (AppColors.firstTripBg, AppColors.firstTripText),
      TripType.second => (AppColors.secondTripBg, AppColors.secondTripText),
    };

    final String label;
    if (direction != null) {
      label = '🚌 $direction: ${type.label}';
    } else {
      label = switch (type) {
        TripType.first => '↑ FIRST',
        TripType.second => '↓ SECOND',
      };
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 8,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(small ? 5 : 7),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
