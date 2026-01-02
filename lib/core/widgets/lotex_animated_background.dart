import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/lotex_ui_tokens.dart';

const bool _kIsTest = bool.fromEnvironment('FLUTTER_TEST');

class LotexAnimatedBackground extends StatefulWidget {
  const LotexAnimatedBackground({super.key});

  @override
  State<LotexAnimatedBackground> createState() => _LotexAnimatedBackgroundState();
}

class _LotexAnimatedBackgroundState extends State<LotexAnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _orb1;
  late final AnimationController _orb2;

  @override
  void initState() {
    super.initState();
    _orb1 = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _orb2 = AnimationController(vsync: this, duration: const Duration(seconds: 15))
      ..repeat();
  }

  @override
  void dispose() {
    _orb1.dispose();
    _orb2.dispose();
    super.dispose();
  }

  double _wave(double t) {
    return (math.sin(t * 2 * math.pi) + 1) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: LotexUiColors.slate950),
            ),
            // Noise overlay
            // NOTE: flutter_svg on Web uses vector_graphics_compiler which doesn't
            // support some SVG features/units (e.g. width="100%" + filters).
            // Our noise SVG uses feTurbulence + percent sizes, so we disable it on Web
            // to avoid runtime FormatException crashes.
            if (!_kIsTest && !kIsWeb)
              Opacity(
                opacity: 0.20,
                child: SvgPicture.asset(
                  'assets/noise.svg',
                  fit: BoxFit.cover,
                ),
              ),

            // Orb #1 (top-left)
            AnimatedBuilder(
              animation: _orb1,
              builder: (context, _) {
                final w = _wave(_orb1.value);
                final scale = 1.0 + 0.2 * w;
                final dx = 100.0 * w;
                final dy = -50.0 * w;
                final opacity = 0.30 + 0.20 * w;

                return Positioned(
                  top: 0,
                  left: 0,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                          child: Container(
                            width: 500,
                            height: 500,
                            decoration: BoxDecoration(
                              color: LotexUiColors.violet900.withAlpha((0.40 * 255).round()),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Orb #2 (bottom-right)
            AnimatedBuilder(
              animation: _orb2,
              builder: (context, _) {
                final w = _wave(_orb2.value);
                final scale = 1.0 + 0.2 * (1 - w);
                final dx = -100.0 * w;
                final dy = 50.0 * w;
                final opacity = 0.30 + 0.20 * w;

                return Positioned(
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                          child: Container(
                            width: 600,
                            height: 600,
                            decoration: BoxDecoration(
                              color: LotexUiColors.blue900.withAlpha((0.30 * 255).round()),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Orb #3 (center)
            Positioned.fill(
              child: Center(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 800,
                    height: 800,
                    decoration: BoxDecoration(
                      color: LotexUiColors.indigo950.withAlpha((0.20 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
