import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routing/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Navigate after 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go(AppRoutes.schools);
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Centre group ──────────────────────────────────────────────
            // Center widget gives this column a guaranteed geometric centre
            // regardless of SafeArea insets or screen aspect ratio.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.airport_shuttle_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title — textAlign ensures the glyphs themselves are centred,
                  // not just the Text widget's bounding box.
                  Text(
                    'Alphonsa Van Service',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Student Management',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(191),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Animated loading dots
                  _AnimatedDots(controller: _dotController),
                ],
              ),
            ),

            // ── Version — pinned to the bottom, not part of the flex tree ──
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Text(
                'v2.0.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.white.withAlpha(115),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(opacity: _opacity(v, 0)),
            const SizedBox(width: 7),
            _Dot(opacity: _opacity(v, 1)),
            const SizedBox(width: 7),
            _Dot(opacity: _opacity(v, 2)),
          ],
        );
      },
    );
  }

  double _opacity(double v, int index) {
    final shifted = (v + index / 3) % 1.0;
    return shifted < 0.5 ? 1.0 : 0.25;
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: const SizedBox(
        width: 9,
        height: 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
